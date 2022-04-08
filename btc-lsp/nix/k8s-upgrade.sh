#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
BITCOIN_NETWORK="regtest"
SETUP_MODE="keep"
SERVICES=""
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"
K8S_CTX=`kubectl config current-context || echo ""`

if [ -z "$*" ]; then
  echo "==> Using defaults"
else
  for ARG in "$@"; do
    case $ARG in
      --regtest|regtest)
        BITCOIN_NETWORK="regtest"
        shift
        ;;
      --testnet|testnet)
        BITCOIN_NETWORK="testnet"
        shift
        ;;
      --mainnet|mainnet)
        BITCOIN_NETWORK="mainnet"
        shift
        ;;
      --source|source)
        SETUP_MODE="source"
        shift
        ;;
      --prebuilt|prebuilt)
        SETUP_MODE="prebuilt"
        shift
        ;;
      --keep|keep)
        SETUP_MODE="keep"
        shift
        ;;
      *)
        break
        ;;
    esac
  done
fi
SERVICES="$@"

read -r -p "==> Confirm upgrade

  BITCOIN_NETWORK=$BITCOIN_NETWORK
  SETUP_MODE=$SETUP_MODE
  SERVICES='$SERVICES'
  GITHUB_RELEASE=$GITHUB_RELEASE
  K8S_CTX=$K8S_CTX

[y/n]> " REPLY

case $REPLY in
  y)
    true
    ;;
  *)
    echo "==> Upgrade cancelled"
    exit 1
    ;;
esac

if [ "$BITCOIN_NETWORK" = "regtest" ]; then
  case "$SETUP_MODE" in
    source)
      echo "==> Building from source"
      sh "$THIS_DIR/hm-release.sh"
      ;;
    prebuilt)
      (
        echo "==> Using prebuilt"
        cd "$BUILD_DIR"
        rm -rf docker-image-*
        wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-btc-lsp.tar.gz"
      )
      ;;
    keep)
      echo "==> Keeping version"
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

  echo "==> Setting default minikube profile"
  sh "$THIS_DIR/mk-setup-profile.sh"

  echo "==> Loading btc-lsp docker image into minikube"
  minikube image load \
    --daemon=true \
    $(cat "$BUILD_DIR/docker-image-btc-lsp.txt")
fi

echo "==> Generating updated k8s resources"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh $BITCOIN_NETWORK'"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh" "$SERVICES"
