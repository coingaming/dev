#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"

(
  echo "==> Generating electrs cfg"
  SERVICE_DIR="$SHELL_DIR/electrs"
  mkdir -p "$SERVICE_DIR/db"
  echo 'auth="developer:developer"' > "$SERVICE_DIR/electrs.toml"
)

echo "==> Generated cfgs"
