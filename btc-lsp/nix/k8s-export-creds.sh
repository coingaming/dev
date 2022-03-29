#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
EXPORTS_DIR="$THIS_DIR/../build/exports"

mkdir -p "$EXPORTS_DIR"

for OWNER in lsp; do
  LND_SERVICE="lnd"
  LND_POD=`sh $THIS_DIR/k8s-get-pod.sh $LND_SERVICE`

  ( echo "$LND_SERVICE ==> exporting creds from $LND_POD" \
    && kubectl cp "default/$LND_POD:/root/.lnd" "$EXPORTS_DIR/$LND_SERVICE" ) \
  || true
done
