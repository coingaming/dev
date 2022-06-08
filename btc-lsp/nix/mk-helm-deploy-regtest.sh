#!/bin/sh

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
  $(cat "$BUILD_DIR/docker-image-btc-lsp.txt")

if [ "$INTEGRATION" = "enabled" ]; then
  echo "==> Loading integration docker image"
  docker load -q -i "$BUILD_DIR/docker-image-integration.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-integration.txt"

  echo "==> Loading integration docker image into minikube"
  minikube image load \
  --daemon=true \
  $(cat "$BUILD_DIR/docker-image-integration.txt")
fi

for HELM_CHART_NAME in bitcoind lnd rtl postgres lsp; do
  echo "==> Installing \"$HELM_CHART_NAME\" chart"
  helm install "$HELM_CHART_NAME" "$HELM_REPO_NAME/$HELM_CHART_NAME"
done

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "bitcoind lnd postgres"

echo "==> Initializing LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Exporting LND creds"
sh "$THIS_DIR/k8s-export-creds.sh"

export LND_HEX_MACAROON="$(cat "$LND_PATH/macaroon.hex" | tr -d '\r' | tr -d '\n')"
export LND_TLS_CERT="$(cat "$LND_PATH/tls.cert" | awk 'NF {sub(/\r/, ""); printf "%s\\r\\n",$0;}')"

# Provide btc-lsp image repo and tag as ENV vars
BTC_LSP_DOCKER_IMAGE="$(cat "$BUILD_DIR/docker-image-btc-lsp.txt")"
IFS=':' read -ra BTC_LSP_DOCKER_IMAGE_DATA <<< "$BTC_LSP_DOCKER_IMAGE"

export LSP_IMAGE_REPO="${BTC_LSP_DOCKER_IMAGE_DATA[0]}"
export LSP_IMAGE_TAG="${BTC_LSP_DOCKER_IMAGE_DATA[1]}"

echo "==> Using \"$LSP_IMAGE_REPO:$LSP_IMAGE_TAG\" image for btc-lsp"

for HELM_CHART_NAME in rtl lsp; do
  echo "==> Configuring \"$HELM_CHART_NAME\" values with LND creds"
  envsubst < "$THIS_DIR/../helm/$HELM_CHART_NAME.env.yaml" | \
  tee "$THIS_DIR/../build/$HELM_CHART_NAME.yaml"

  echo "==> Upgrading \"$HELM_CHART_NAME\" chart"
  helm upgrade \
    --values "$THIS_DIR/../build/$HELM_CHART_NAME.yaml" \
    "$HELM_CHART_NAME" \
    "$HELM_REPO_NAME/$HELM_CHART_NAME"
done

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Mine initial coins"
sh "$THIS_DIR/k8s-mine.sh" 105

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
