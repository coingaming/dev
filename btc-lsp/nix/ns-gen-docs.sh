#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

plantuml "$THIS_DIR/../docs/plantuml/*.txt"

echo "docs ==> generated!"
