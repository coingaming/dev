#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

mkdir -p "$BUILD_DIR"

echo "==> Docker build cleanup"
sh "$THIS_DIR/ds-down.sh" || true
rm -rf "$BUILD_DIR/swarm"

echo "==> Docker swarm network setup"
if [ "$1" = "--reset-swarm" ]; then
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

echo "==> Docker image build"
sh "$THIS_DIR/hm-release.sh"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

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
