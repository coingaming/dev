#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK="${1:-regtest}"

if [ "$BITCOIN_NETWORK" = "regtest" ]; then
  POSTGRES_USER=`sh $THIS_DIR/k8s-get-secret.sh postgres postgres_user`
  sh "$THIS_DIR/k8s-exec.sh" "postgres" "psql -U $POSTGRES_USER $POSTGRES_USER"
elif [ "$BITCOIN_NETWORK" = "testnet" ]; then
  PG_INSTANCE_ID=`doctl databases list --no-header | grep "lsp-$BITCOIN_NETWORK" | awk '{print $1}'`
  CONN_STR=`doctl databases connection $PG_INSTANCE_ID --no-header --format URI`
  psql -Atx "$CONN_STR"
elif [ "$BITCOIN_NETWORK" = "mainnet" ]; then
  echo "TODO"
else
  echo "Please specify bitcoin network (regtest/testnet/mainnet)"
fi
