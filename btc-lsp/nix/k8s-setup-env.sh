#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SCRIPTS_DIR="$THIS_DIR/../build/scripts"
BITCOIN_NETWORK="$1"

sh "$SCRIPTS_DIR/setup-bitcoind-env.sh"
sh "$SCRIPTS_DIR/setup-lnd-env.sh"
sh "$SCRIPTS_DIR/setup-rtl-env.sh $BITCOIN_NETWORK" 

if [ $BITCOIN_NETWORK = "regtest" ]; then
  sh "$SCRIPTS_DIR/setup-postgres-env.sh"
fi

sh "$SCRIPTS_DIR/setup-lsp-env.sh"
