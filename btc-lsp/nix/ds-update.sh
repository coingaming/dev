#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

echo "==> Compiling dhall"
sh "$THIS_DIR/shell-docker.sh" --mini \
   "--run './nix/dhall-compile.sh'"

sh -c "$THIS_DIR/ds-down.sh $1"
sh -c "$THIS_DIR/ds-up.sh $1"
