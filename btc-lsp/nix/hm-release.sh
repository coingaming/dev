#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

rm -rf "$THIS_DIR/../build/docker-image-btc-lsp.tar.gz"
mkdir -p "$THIS_DIR/../build"

sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run './nix/ns-release.sh && \
   cp -Lr ./result ./build/docker-image-btc-lsp.tar.gz'
   "
