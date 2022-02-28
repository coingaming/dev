#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
EXPORTED_CREDS_DIR="$THIS_DIR/../build/exported-creds"

mkdir -p "$EXPORTED_CREDS_DIR"

for OWNER in lsp; do
  LND_SERVICE="lnd-$OWNER"
  LND_POD=`kubectl get pods --no-headers -o custom-columns=":metadata.name" --selector=io.kompose.service=$LND_SERVICE`

  ( echo "$LND_SERVICE ==> exporting creds from $LND_POD" \
    && kubectl cp "default/$LND_POD:/root/.lnd" "$EXPORTED_CREDS_DIR/lnd-$OWNER" ) \
  || true
done