#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BASE_DIR="$THIS_DIR/.."
PROTO_DIR="$BASE_DIR/proto"

gen_haskell() {
  #
  # Haskell
  #
  # To install Haskell protoc plugin without nix,
  # run `stack install proto-lens-protoc` and the
  # same for `signable-haskell-protoc`.
  #
  # Haskell stack is needed for this as well
  # https://docs.haskellstack.org/
  #
  # In general - it's much better just to use nix.
  # To spawn nix shell, run `./nix/shell.sh`.
  #
  local HASKELL_DIR="$BASE_DIR"
  local HASKELL_SRC_DIR="$HASKELL_DIR/src"
  local HASKELL_SRC_PROTO_LENS_DIR="$HASKELL_SRC_DIR/Proto"

  echo "==> Haskell (proto-lens) - trying to generate $HASKELL_SRC_PROTO_LENS_DIR"
  rm -rf $HASKELL_SRC_PROTO_LENS_DIR
  mkdir -p $HASKELL_SRC_PROTO_LENS_DIR
  (cd $PROTO_DIR && protoc \
    ./*.proto \
    ./**/**/*.proto \
    --plugin=protoc-gen-haskell=`which proto-lens-protoc` \
    --haskell_out=$HASKELL_SRC_DIR \
    --haskell_opt='Opt{ imports = ["Text.PrettyPrint.GenericPretty.Instance"], pragmas = ["DeriveGeneric"], stockInstances = ["GHC.Generics.Generic"], defaultInstances = ["Text.PrettyPrint.GenericPretty.Out"] }')
  echo "==> Haskell (proto-lens) - generated proto types in $HASKELL_SRC_PROTO_LENS_DIR"
  (cd $PROTO_DIR && protoc \
    ./*.proto \
    ./**/**/*.proto \
    --plugin=protoc-gen-signable=`which signable-haskell-protoc` \
    --signable_out=$HASKELL_SRC_DIR)
  echo "==> Haskell (proto-lens) - generated orphan Signable instances in $HASKELL_SRC_PROTO_LENS_DIR"
}

gen_all() {
  gen_haskell
}

if [ -z "$*" ]; then
  gen_all
else
  for arg in "$@"
  do
    case $arg in
      -h|--haskell|haskell)
      gen_haskell
      shift
      ;;
      -a|--all|all)
      gen_all
      break
      ;;
    esac
  done
fi
