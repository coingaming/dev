#!/bin/sh

set -e

setup () {
  ROW="127.0.0.1 yolo_$1"
  grep -q "$ROW" /etc/hosts || echo "$ROW" >> /etc/hosts
}

setup "postgres"
setup "bitcoind"

for OWNER in lsp alice bob; do
  setup "lnd-$OWNER"
done

setup "rtl"
setup "btc-lsp"
