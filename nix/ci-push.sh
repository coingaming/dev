#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_NIX_DIR="$THIS_DIR/../btc-lsp/nix"
BTC_LSP_BUILD_DIR="$THIS_DIR/../btc-lsp/build"
VERSION="$(cat "$THIS_DIR/../VERSION" | tr -d '\n')"

for APP in btc-lsp electrs integration; do
  OLD_TAG=`cat "$BTC_LSP_BUILD_DIR/docker-image-$APP.txt"`
  NEW_TAG="ghcr.io/coingaming/$APP:$VERSION"
  echo "$APP ==> Tag $OLD_TAG -> $NEW_TAG"
  docker tag "$OLD_TAG" "$NEW_TAG"
  echo "$APP ==> Push $NEW_TAG"
  docker push "$NEW_TAG"
done

