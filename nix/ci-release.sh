#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_NIX_DIR="$THIS_DIR/../btc-lsp/nix"
BTC_LSP_BUILD_DIR="$THIS_DIR/../btc-lsp/build"

echo "btc-lsp ==> Binaries build"
sh "$BTC_LSP_NIX_DIR/hm-release.sh" --github

echo "btc-lsp ==> Chown"
sudo chown -R $USER:$USER "$BTC_LSP_BUILD_DIR"

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

echo "btc-lsp ==> Chown"
sudo chown -R $USER:$USER "$BTC_LSP_BUILD_DIR"
