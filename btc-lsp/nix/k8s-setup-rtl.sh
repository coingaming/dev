#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE=rtl

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Setting up $BITCOIN_NETWORK env for $SERVICE"

. "$THIS_DIR/../build/kubernetes/$BITCOIN_NETWORK/$SERVICE.sh"

(kubectl create secret generic "$SERVICE" \
  --from-literal=rtl_config_nodes_json="$RTL_CONFIG_NODES_JSON" \
  --from-literal=rtl_config_json="$RTL_CONFIG_JSON") || true

if [ $BITCOIN_NETWORK != "regtest" ]; then
  (kubectl create secret tls "$SERVICE-tls" \
  --cert="$THIS_DIR/../build/swarm/$SERVICE/tls.crt" \
  --key="$THIS_DIR/../build/swarm/$SERVICE/tls.key") || true
fi

(kubectl create configmap "$SERVICE" \
  --from-literal=config_from_env="$CONFIG_FROM_ENV") || true
