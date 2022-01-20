#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> docker swarm network setup"
sh "$THIS_DIR/ds-down.sh" || true
docker swarm leave --force || true
docker swarm init || true
docker network create -d overlay --attachable global || true

echo "==> keys generation"
sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run './nix/generate-tls-cert.sh'"

echo "==> docker image build"
sh "$THIS_DIR/release-docker.sh"
docker load -q -i "$BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BUILD_DIR/docker-image-btc-lsp.txt"

echo "==> dhall compilation"
sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run './nix/dhall-compile.sh'"

sh "$THIS_DIR/ds-up.sh"
