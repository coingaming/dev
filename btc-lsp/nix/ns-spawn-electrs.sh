#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

ELECTRS_DIR="$THIS_DIR/../build/shell/electrs"
BITCOIN_DIR="$THIS_DIR/../build/shell/bitcoind"

echo "==> starting electrs..."

mkdir -p "$ELECTRS_DIR/db"

RUST_LOG=debug electrs \
  --conf="$ELECTRS_DIR/electrs.toml" \
  --db-dir="$ELECTRS_DIR/db" \
  --daemon-dir="$BITCOIN_DIR" \
  --blocks-dir="$BITCOIN_DIR/regtest/blocks" \
  --network=regtest \
  --electrum-rpc-addr="127.0.0.1:60401" \
  --daemon-rpc-addr="127.0.0.1:20000" \
  --timestamp \
  --verbose \
  > $ELECTRS_DIR/stdout.log 2>&1 & \
  echo "$!" > "$ELECTRS_DIR/electrs.pid"

  #--jsonrpc-import
  #--wait-duration-secs
  #--index-batch-size
  #--bulk-index-threads
  #--tx-cache-size-mb
  #--blocktxids-cache-size-mb
  #--txid-limit
  #--server-banner
  #--conf
  #--cookie-file
  #--monitoring-addr

echo "==> electrs has been started!"
