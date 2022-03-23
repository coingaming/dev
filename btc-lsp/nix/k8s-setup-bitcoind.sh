#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE=bitcoind

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Setting up $BITCOIN_NETWORK env for $SERVICE"

. "$THIS_DIR/../build/kubernetes/$BITCOIN_NETWORK/$SERVICE.sh"

(kubectl create configmap "$SERVICE" \
  --from-literal=config_from_env="$CONFIG_FROM_ENV" \
  --from-literal=disablewallet="$DISABLEWALLET" \
  --from-literal=prune="$PRUNE" \
  --from-literal=regtest="$REGTEST" \
  --from-literal=rpcallowip="$RPCALLOWIP" \
  --from-literal=rpcbind="$RPCBIND" \
  --from-literal=rpcport="$RPCPORT" \
  --from-literal=server="$SERVER" \
  --from-literal=testnet="$TESTNET" \
  --from-literal=txindex="$TXINDEX" \
  --from-literal=zmqpubrawblock="$ZMQPUBRAWBLOCK" \
  --from-literal=zmqpubrawtx="$ZMQPUBRAWTX") || true

(kubectl create secret generic "$SERVICE" \
  --from-literal=rpcuser="$RPCUSER" \
  --from-literal=rpcpassword="$RPCPASSWORD") || true
