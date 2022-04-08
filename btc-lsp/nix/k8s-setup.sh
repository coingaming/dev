#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SETUP_MODE="--prebuilt"
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"
BITCOIN_NETWORK="regtest"

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
      *)
        echo "==> unrecognized arg $arg"
        exit 1
        ;;
    esac
  done
fi

echo "==> Setup $BITCOIN_NETWORK kubernetes cluster"
sh "$THIS_DIR/mk-setup-cluster.sh"

echo "==> Clean up build"
rm -rf "$BUILD_DIR" && mkdir -p "$BUILD_DIR"

echo "==> Generate creds"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-gen-creds.sh'"

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
    )
    ;;
  *)
    echo "==> Unrecognized SETUP_MODE $SETUP_MODE"
    exit 1
    ;;
esac

echo "==> Loading btc-lsp docker image"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

echo "==> Loading btc-lsp docker image into minikube"
minikube image load \
  --daemon=true \
  $(cat "$BUILD_DIR/docker-image-btc-lsp.txt")

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "bitcoind lnd lnd-alice lnd-bob postgres"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "bitcoind lnd lnd-alice lnd-bob postgres"

echo "==> Initializing LND wallet"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"

echo "==> Exporting creds from running pods"
sh "$THIS_DIR/k8s-export-creds.sh"

echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "==> Configuring environment for containers"
sh "$THIS_DIR/k8s-setup-env.sh"

echo "==> Deploying additional k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "rtl lsp"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh" "rtl lsp"

echo "==> Mine initial coins"
sh "$THIS_DIR/k8s-mine.sh" 105

echo "==> Setup for $BITCOIN_NETWORK has been completed!"
