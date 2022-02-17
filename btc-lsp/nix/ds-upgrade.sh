#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

SETUP_MODE="--keep"
GITHUB_RELEASE="v0.1.0"

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

sh -c "$THIS_DIR/ds-down.sh $1"

case $SETUP_MODE in
  --source)
    echo "==> Building from source"
    sh "$THIS_DIR/hm-release.sh"
    docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
      | awk '{print $NF}' \
      | tr -d '\n' \
      > "$BUILD_DIR/docker-image-btc-lsp.txt"
    sh -c "$THIS_DIR/ds-update.sh"
    ;;
  --prebuilt)
    echo "==> Using prebuilt"
    exit 1
    # cd "$BUILD_DIR"
    # wget "https://github.com/21it/src/releases/download/$GITHUB_RELEASE/docker-image-btc-lsp.tar.gz"
    # wget "https://github.com/21it/src/releases/download/$GITHUB_RELEASE/docker-compose.yolo.yml"
    ;;
  --keep)
    echo "==> Keeping version"
    sh -c "$THIS_DIR/ds-update.sh"
    ;;
  *)
    echo "==> Unrecognized SETUP_MODE $SETUP_MODE"
    exit 1
    ;;
esac
