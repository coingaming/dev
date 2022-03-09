#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
mkdir -p "$THIS_DIR/../build"

RELEASE_TARGET=all
if [ -z "$*" ]; then
  true
else
  for arg in "$@"
  do
    case $arg in
      all|--all)
        RELEASE_TARGET="all"
        shift
        ;;
      btc-lsp|--btc-lsp)
        RELEASE_TARGET="btc-lsp"
        shift
        ;;
      electrs|--electrs)
        RELEASE_TARGET="electrs"
        shift
        ;;
      *)
        break
        ;;
    esac
  done
fi
NIX_EXTRA_ARGS="$@"

release_btc_lsp () {
  rm -rf "$THIS_DIR/../build/docker-image-btc-lsp.tar.gz"
  rm -rf "$THIS_DIR/../build/docker-image-btc-lsp.txt"
  sh "$THIS_DIR/hm-shell-docker.sh" --mini "$NIX_EXTRA_ARGS" \
     "--run './nix/ns-release.sh docker.nix && \
     cp -Lr ./result ./build/docker-image-btc-lsp.tar.gz'
     "
}

release_electrs () {
  rm -rf "$THIS_DIR/../build/docker-image-electrs.tar.gz"
  rm -rf "$THIS_DIR/../build/docker-image-electrs.txt"
  sh "$THIS_DIR/hm-shell-docker.sh" --mini "$NIX_EXTRA_ARGS" \
     "--run './nix/ns-release.sh docker-image-electrs.nix && \
     cp -Lr ./result ./build/docker-image-electrs.tar.gz'
     "
}

release_all () {
  release_electrs
  release_btc_lsp
}

case $RELEASE_TARGET in
  all)
    echo "==> Release all"
    release_all
    ;;
  btc-lsp)
    echo "==> Release btc-lsp"
    release_btc_lsp
    ;;
  electrs)
    echo "==> Release electrs"
    release_electrs
    ;;
  *)
    echo "==> Unrecognized RELEASE_TARGET $RELEASE_TARGET"
    exit 1
    ;;
esac
