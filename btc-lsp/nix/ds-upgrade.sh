#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh -c "$THIS_DIR/ds-down.sh $1"
sh -c "$THIS_DIR/ds-update.sh"
