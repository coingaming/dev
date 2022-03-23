#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE=lnd

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Setting up $BITCOIN_NETWORK env for $SERVICE"

. "$THIS_DIR/../build/kubernetes/$BITCOIN_NETWORK/$SERVICE.sh"

(kubectl create configmap "$SERVICE" \
  --from-literal=bitcoin_defaultchanconfs="$BITCOIN_DEFAULTCHANCONFS" \
  --from-literal=bitcoin_network="$BITCOIN_NETWORK" \
  --from-literal=bitcoin_rpchost="$BITCOIN_RPCHOST" \
  --from-literal=bitcoin_zmqpubrawblock="$BITCOIN_ZMQPUBRAWBLOCK" \
  --from-literal=bitcoin_zmqpubrawtx="$BITCOIN_ZMQPUBRAWTX" \
  --from-literal=lnd_grpc_port="$LND_GRPC_PORT" \
  --from-literal=lnd_p2p_port="$LND_P2P_PORT" \
  --from-literal=lnd_rest_port="$LND_REST_PORT") || true

(kubectl create secret generic "$SERVICE" \
  --from-literal=bitcoin_rpcuser="$BITCOIN_RPCUSER" \
  --from-literal=bitcoin_rpcpass="$BITCOIN_RPCPASS") || true
