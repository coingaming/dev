#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BTC_LSP_BUILD_DIR="$THIS_DIR/../btc-lsp/build"
ELECTRS_CLIENT_BUILD_DIR="$THIS_DIR/../electrs-client/build"
VERSION="$(cat "$THIS_DIR/../VERSION" | tr -d '\n')"

dockerpush () {
  APP=$1
  DIR=$2
  OLD_TAG=`cat "$DIR/docker-image-$APP.txt"`
  NEW_TAG="ghcr.io/coingaming/$APP:$VERSION"
  echo "$APP ==> Tag $OLD_TAG -> $NEW_TAG"
  docker tag "$OLD_TAG" "$NEW_TAG"
  echo "$APP ==> Push $NEW_TAG"
  docker push "$NEW_TAG"
}

dockerpush btc-lsp $BTC_LSP_BUILD_DIR
dockerpush integration $BTC_LSP_BUILD_DIR
dockerpush electrs $ELECTRS_CLIENT_BUILD_DIR
