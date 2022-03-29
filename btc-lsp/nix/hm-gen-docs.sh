#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/hm-shell-docker.sh" --mini \
   "--run './nix/ns-gen-docs.sh'"
