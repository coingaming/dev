#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_BUILD_DIR="$THIS_DIR/../btc-lsp/build"
ELECTRS_CLIENT_BUILD_DIR="$THIS_DIR/../electrs-client/build"
mkdir -p "$BTC_LSP_BUILD_DIR/build"
mkdir -p "$ELECTRS_CLIENT_BUILD_DIR/build"

pwd
ls -la

echo "btc-lsp ==> Binaries build"
nix-build btc-lsp/nix/docker.nix --out-link "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.tar.gz"
nix-build btc-lsp/nix/docker-integration.nix --out-link "$BTC_LSP_BUILD_DIR/docker-image-integration.tar.gz"
nix-build electrs-client/nix/docker-image-electrs.nix --out-link "$ELECTRS_CLIENT_BUILD_DIR/docker-image-electrs.tar.gz"

echo "btc-lsp ==> Docker btc-lsp image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.txt"

echo "integration ==> Docker integration image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-integration.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-integration.txt"

echo "electrs ==> Docker electrs image verification"
docker load -q -i \
  "$ELECTRS_CLIENT_BUILD_DIR/docker-image-electrs.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$ELECTRS_CLIENT_BUILD_DIR/docker-image-electrs.txt"
