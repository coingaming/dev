#!/bin/sh

THIS_DIR="$(pwd)"

OWNER="$1"
LND_DIR="$THIS_DIR/build/shell/lnd-$OWNER"
DATA_DIR="$LND_DIR/data/chain/bitcoin/regtest"

echo "==> starting lnd-$OWNER..."
mkdir -p "$DATA_DIR"
cp $THIS_DIR/test/Macaroon/*macaroon* "$DATA_DIR/"
lnd --lnddir=$LND_DIR --bitcoin.defaultchanconfs=1 \
  > "$LND_DIR/stdout.log" \
  & echo "$!" \
  > "$LND_DIR/lnd.pid"

echo "==> lnd-$OWNER has been started!"
