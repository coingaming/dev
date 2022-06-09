#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK="${1:-regtest}"
POSTGRES_USER="$(sh "$THIS_DIR/k8s-get-secret.sh" postgres postgres_user)"

sh "$THIS_DIR/k8s-exec.sh" "postgres" "psql -U $POSTGRES_USER $POSTGRES_USER"
