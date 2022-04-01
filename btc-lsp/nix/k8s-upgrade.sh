#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SETUP_MODE="--keep"
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"

if [ -z "$*" ]; then
  echo "==> Using defaults"
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
      --keep)
        SETUP_MODE="$arg"
        shift
        ;;
      *)
        echo "==> Unrecognized arg $arg"
        exit 1
        ;;
    esac
  done
fi

case "$SETUP_MODE" in
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
  --keep)
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

echo "==> Generating updated k8s resources"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "==> Deploying k8s resources"
sh "$THIS_DIR/k8s-deploy.sh"
