#!/bin/sh

. nix/export-test-envs.sh

THIS_DIR="$(pwd)"

LND_DIR="$1"
LND_LBL="$2"

echo "starting lnd-${LND_LBL}..."
cp $THIS_DIR/.lnd/tls* "$LND_DIR/"
mkdir -p "$LND_DIR/data/chain/bitcoin/regtest/"
cp $THIS_DIR/.lnd/*macaroon* "$LND_DIR/data/chain/bitcoin/regtest/"
lnd --lnddir=$LND_DIR --bitcoin.defaultchanconfs=1 > $LND_DIR/stdout.log & echo "$!" > "$LND_DIR/lnd.pid"

echo "lnd-${LND_LBL} has been started!"
