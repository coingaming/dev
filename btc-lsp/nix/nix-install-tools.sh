#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

nix-env -i -f "$THIS_DIR/tools.nix"
