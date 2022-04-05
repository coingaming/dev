#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SETUP_MODE="--source"
RESET_SWARM="false"
GITHUB_RELEASE="$(cat "$THIS_DIR/../../VERSION" | tr -d '\n')"

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
      --reset-swarm)
        RESET_SWARM="true"
        shift
        ;;
      *)
        echo "==> unrecognized arg $arg"
        exit 1
        ;;
    esac
  done
fi

mkdir -p "$BUILD_DIR"

echo "==> Docker build cleanup"
sh "$THIS_DIR/ds-down.sh" || true
sleep 5
rm -rf "$BUILD_DIR/swarm"

echo "==> Docker swarm network setup"
if [ "$RESET_SWARM" = "true" ]; then
  echo "==> DOING SWARM RESET"
  docker swarm leave --force || true
  docker swarm init || true
else
  echo "==> using existing swarm"
fi
docker network create -d overlay --attachable global || true

echo "==> Docker volume cleanup"
docker volume rm $(docker volume ls -q | grep yolo_) || true

echo "==> Gen keys"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-gen-keys.sh'"

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
      wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-electrs.tar.gz"
      wget "https://github.com/coingaming/src/releases/download/$GITHUB_RELEASE/docker-image-integration.tar.gz"
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

echo "==> Loading electrs docker image"
docker load -q -i "$BUILD_DIR/docker-image-electrs.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-electrs.txt"

echo "==> Partial dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "==> Partial spin"
sh "$THIS_DIR/ds-up.sh"
sleep 10

echo "==> Gen creds"
sh "$THIS_DIR/ds-gen-creds.sh"

echo "==> Full dhall"
sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "==> Full spin"
sh "$THIS_DIR/ds-up.sh"
sleep 10

echo "==> Mine initial coins"
sh "$THIS_DIR/ds-mine.sh" 105
sleep 10
