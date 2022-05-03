#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_BUILD_DIR="$THIS_DIR/build"
mkdir -p "$THIS_DIR/build"

echo "btc-lsp ==> Binaries build"
nix-build docker.nix --out-link "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.tar.gz"
nix-build docker-image-electrs.nix --out-link "$BTC_LSP_BUILD_DIR/docker-image-electrs.tar.gz"
nix-build docker-integration.nix --out-link "$BTC_LSP_BUILD_DIR/docker-image-integration.tar.gz"

echo "btc-lsp ==> Docker btc-lsp image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.txt"

echo "electrs ==> Docker electrs image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-electrs.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-electrs.txt"

echo "integration ==> Docker integration image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-integration.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-integration.txt"
