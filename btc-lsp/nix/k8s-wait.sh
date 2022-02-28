#!/bin/sh

set -e

check_state () {
  echo "Waiting till $1 is up and running..."
  kubectl wait pod --for condition=ready --timeout=300s --selector="io.kompose.service=$1"
  echo "Success! $1 is up and running!"
}

if [ "$1" = "yolo" ]; then
  for MEMBER in bitcoind btc-lsp lnd-lsp postgres rtl; do
    check_state "$1-$MEMBER"
  done
else
  echo "Unknown stack: $1"
fi
