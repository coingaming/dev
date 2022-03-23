#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE=postgres

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Setting up $BITCOIN_NETWORK env for $SERVICE"

. "$THIS_DIR/../build/kubernetes/$BITCOIN_NETWORK/$SERVICE.sh"

(kubectl create secret generic "$SERVICE" \
  --from-literal=postgres_user="$POSTGRES_USER" \
  --from-literal=postgres_password="$POSTGRES_PASS") || true

(kubectl create configmap "$SERVICE" \
  --from-literal=postgres_multiple_databases="$POSTGRES_DB") || true
