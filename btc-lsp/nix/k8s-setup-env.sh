#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
SCRIPTS_DIR="$BUILD_DIR/scripts"

sh "$SCRIPTS_DIR/setup-bitcoind-env.sh"
sh "$SCRIPTS_DIR/setup-lnd-env.sh"

if [ -f "$SCRIPTS_DIR/setup-lnd-alice-env.sh" ]; then
  sh "$SCRIPTS_DIR/setup-lnd-alice-env.sh"
fi

if [ -f "$SCRIPTS_DIR/setup-lnd-bob-env.sh" ]; then
  sh "$SCRIPTS_DIR/setup-lnd-bob-env.sh"
fi

if [ -f "$SCRIPTS_DIR/setup-postgres-env.sh" ]; then
  sh "$SCRIPTS_DIR/setup-postgres-env.sh"
fi

if [ -f "$SCRIPTS_DIR/setup-integration-env.sh" ]; then
  sh "$SCRIPTS_DIR/setup-integration-env.sh"
fi

if [ -f "$BUILD_DIR/secrets/lnd/macaroon.hex" ]; then
  sh "$SCRIPTS_DIR/setup-rtl-env.sh"
  sh "$SCRIPTS_DIR/setup-lsp-env.sh"
fi
