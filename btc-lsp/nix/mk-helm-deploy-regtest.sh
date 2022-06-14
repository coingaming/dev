#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/utilities.sh"

SETUP_MODE="--prebuilt"
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"
BITCOIN_NETWORK="regtest"
HELM_REPO_NAME="yolo"
INTEGRATION="disabled"

if [ -z "$*" ]; then
  echo "==> using defaults"
else
  for arg in "$@"; do
    case $arg in
      --source)
        SETUP_MODE="$arg"
        shift
        ;;
      --prebuilt)
        SETUP_MODE="$arg"
        shift
        ;;
      --integration)
        INTEGRATION="enabled"
        shift
        ;;
      *)
        echo "==> unrecognized arg $arg"
        exit 1
        ;;
    esac
  done
fi

confirmAction \
"==> Setup minikube cluster" \
"sh $THIS_DIR/mk-setup-cluster.sh"

echo "==> Clean up previous build"
cleanBuildDir

case $SETUP_MODE in
  --source)
    echo "==> Building from source"
    sh "$THIS_DIR/hm-release.sh"
    ;;
  --prebuilt)
    (
      echo "==> Using prebuilt"
      cd "$BUILD_DIR"
      rm -rf docker-image-*
      wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-btc-lsp.tar.gz"
      if [ "$INTEGRATION" = "enabled" ]; then
        wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-integration.tar.gz"
      fi
    )
    ;;
  *)
    echo "==> Unrecognized SETUP_MODE $SETUP_MODE"
    exit 1
    ;;
esac

echo "==> Checking if \"$HELM_REPO_NAME\" repo exists"
if helm repo list | grep "$HELM_REPO_NAME"; then
  echo "==> Updating \"$HELM_REPO_NAME\" repo"
  helm repo update "$HELM_REPO_NAME"
else
  echo "Repo \"$HELM_REPO_NAME\" does not exist."
  echo "Please provide your github token to add \"$HELM_REPO_NAME\" repo:"
  read -r -s GITHUB_TOKEN
  helm repo add "$HELM_REPO_NAME" \
    --username "${GITHUB_TOKEN}" \
    --password "${GITHUB_TOKEN}" \
    https://raw.githubusercontent.com/coingaming/helm-charts/releases/charts
fi

echo "==> Loading btc-lsp docker image"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

echo "==> Loading btc-lsp docker image into minikube"
minikube image load \
  --daemon=true \
  "$(cat "$BUILD_DIR/docker-image-btc-lsp.txt")"

if [ "$INTEGRATION" = "enabled" ]; then
  echo "==> Loading integration docker image"
  docker load -q -i "$BUILD_DIR/docker-image-integration.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-integration.txt"

  echo "==> Loading integration docker image into minikube"
  minikube image load \
  --daemon=true \
  "$(cat "$BUILD_DIR/docker-image-integration.txt")"
fi

installChart () {
  RELEASE_NAME="$1"
  CHART_NAME="$2"

  echo "==> Installing \"$RELEASE_NAME\" release from \"$CHART_NAME\" chart"
  helm install "$RELEASE_NAME" "$CHART_NAME"
}

for RELEASE_NAME in bitcoind lnd rtl postgres lsp; do
  installChart "$RELEASE_NAME" "$HELM_REPO_NAME/$RELEASE_NAME"
done

installChart "lnd-alice" "$HELM_REPO_NAME/lnd"
installChart "lnd-bob" "$HELM_REPO_NAME/lnd"

if [ "$INTEGRATION" = "enabled" ]; then
  installChart "integration" "$HELM_REPO_NAME/lsp"
fi

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "bitcoind lnd lnd-alice lnd-bob postgres"

echo "==> Initializing LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Exporting LND creds"
sh "$THIS_DIR/k8s-export-creds.sh"

exportMacaroon () {
  local MACAROON_PATH="$1"
  cat "$MACAROON_PATH" | tr -d '\r' | tr -d '\n'
}

exportTlsCert () {
  local TLS_CERT_PATH="$1"
  cat "$TLS_CERT_PATH" | awk 'NF {sub(/\r/, ""); printf "%s\\r\\n",$0;}'
}

export LND_HEX_MACAROON="$(exportMacaroon "$LND_PATH/macaroon.hex")"
export LND_ALICE_HEX_MACAROON="$(exportMacaroon "$LND_ALICE_PATH/macaroon.hex")"
export LND_BOB_HEX_MACAROON="$(exportMacaroon "$LND_BOB_PATH/macaroon.hex")"

export LND_TLS_CERT="$(exportTlsCert "$LND_PATH/tls.cert")"
export LND_ALICE_TLS_CERT="$(exportTlsCert "$LND_ALICE_PATH/tls.cert")"
export LND_BOB_TLS_CERT="$(exportTlsCert "$LND_BOB_PATH/tls.cert")"

# Provide btc-lsp image repo and tag as ENV vars
BTC_LSP_DOCKER_IMAGE="$(cat "$BUILD_DIR/docker-image-btc-lsp.txt")"
IFS=':' read -ra BTC_LSP_DOCKER_IMAGE_DATA <<< "$BTC_LSP_DOCKER_IMAGE"

export LSP_IMAGE_REPO="${BTC_LSP_DOCKER_IMAGE_DATA[0]}"
export LSP_IMAGE_TAG="${BTC_LSP_DOCKER_IMAGE_DATA[1]}"

echo "==> Using \"$LSP_IMAGE_REPO:$LSP_IMAGE_TAG\" image for btc-lsp"

# Provide integration image repo and tag as ENV vars
if [ "$INTEGRATION" = "enabled" ]; then
  INTEGRATION_DOCKER_IMAGE="$(cat "$BUILD_DIR/docker-image-integration.txt")"
  IFS=':' read -ra INTEGRATION_DOCKER_IMAGE_DATA <<< "$INTEGRATION_DOCKER_IMAGE"

  export INTEGRATION_IMAGE_REPO="${INTEGRATION_DOCKER_IMAGE_DATA[0]}"
  export INTEGRATION_IMAGE_TAG="${INTEGRATION_DOCKER_IMAGE_DATA[1]}"

  echo "==> Using \"$INTEGRATION_IMAGE_REPO:$INTEGRATION_IMAGE_TAG\" image for integration"
fi

upgradeRelease () {
  local RELEASE_NAME="$1"
  local CHART_NAME="$2"

  echo "==> Configuring \"$RELEASE_NAME\" values"
  envsubst < "$THIS_DIR/../helm/$RELEASE_NAME.env.yaml" | \
  tee "$THIS_DIR/../build/$RELEASE_NAME.yaml"

  echo "==> Upgrading \"$RELEASE_NAME\" release from \"$CHART_NAME\" chart"
  helm upgrade \
    --values "$THIS_DIR/../build/$RELEASE_NAME.yaml" \
    "$RELEASE_NAME" \
    "$HELM_REPO_NAME/$CHART_NAME"
}

upgradeRelease "lnd" "lnd"
upgradeRelease "lnd-alice" "lnd"
upgradeRelease "lnd-bob" "lnd"
upgradeRelease "rtl" "rtl"
upgradeRelease "lsp" "lsp"

if [ "$INTEGRATION" = "enabled" ]; then
  upgradeRelease "integration" "lsp"
fi

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "lnd lnd-alice lnd-bob rtl lsp"

echo "==> Unlocking LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Mine initial coins"
sh "$THIS_DIR/k8s-mine.sh" 105

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
