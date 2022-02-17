#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_NIX_DIR="$THIS_DIR/../btc-lsp/nix"
BTC_LSP_BUILD_DIR="$THIS_DIR/../btc-lsp/build"

echo "btc-lsp ==> Binaries build"
sh "$BTC_LSP_NIX_DIR/hm-release.sh"

echo "btc-lsp ==> Chown"
sudo chown -R $USER:$USER "$BTC_LSP_BUILD_DIR"

echo "btc-lsp ==> Docker image verification"
docker load -q -i \
  "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.tar.gz" \
  | awk '{print $NF}' \
  | tr -d '\n' \
  > "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.txt"

echo "btc-lsp ==> Dhall compilation"
sh "$BTC_LSP_NIX_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-dhall-compile.sh'"

echo "btc-lsp ==> Chown"
sudo chown -R $USER:$USER "$BTC_LSP_BUILD_DIR"

echo "btc-lsp ==> DEBUG ls "
ls -la "$BTC_LSP_BUILD_DIR"
echo "btc-lsp ==> DEBUG image name"
cat "$BTC_LSP_BUILD_DIR/docker-image-btc-lsp.txt"
echo "btc-lsp ==> DEBUG swarm file"
cat "$BTC_LSP_BUILD_DIR/docker-compose.yolo.yml"
