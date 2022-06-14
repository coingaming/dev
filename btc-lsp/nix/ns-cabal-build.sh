#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

hpack

for X in btc-lsp-exe btc-lsp-integration btc-lsp-test; do
  echo "==> Building $X"
  cabal build --disable-optimization $X
done
