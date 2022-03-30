#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SCRIPTS_DIR="$THIS_DIR/../build/scripts"
BITCOIN_NETWORK=`sh $THIS_DIR/k8s-get-config.sh lnd bitcoin_network`

sh "$SCRIPTS_DIR/setup-bitcoind-env.sh"
sh "$SCRIPTS_DIR/setup-lnd-env.sh"
sh "$SCRIPTS_DIR/setup-rtl-env.sh $BITCOIN_NETWORK" 

if [ $BITCOIN_NETWORK = "regtest" ]; then
  sh "$SCRIPTS_DIR/setup-postgres-env.sh"
fi

sh "$SCRIPTS_DIR/setup-lsp-env.sh"
