#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

trap "hp2pretty $THIS_DIR/../btc-lsp-prof.hp && firefox $THIS_DIR/../btc-lsp-prof.svg" EXIT HUP INT QUIT PIPE TERM

(
  cd "$THIS_DIR/.."
  . "$THIS_DIR/ns-export-test-envs.sh"
  hpack
  cabal run btc-lsp-prof --enable-profiling
)
