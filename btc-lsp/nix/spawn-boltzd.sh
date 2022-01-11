#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

BUILD_DIR="$THIS_DIR/../build"
BOLTZD_DIR="$THIS_DIR/../.boltzd"
LND_DIR="$THIS_DIR/../.lnd-payments"

echo "starting boltzd..."

mkdir -p "$BOLTZD_DIR"

boltzd \
  --datadir="$BOLTZD_DIR" \
  --lnd.host="127.0.0.1" \
  --lnd.port=11009 \
  --lnd.macaroon="$LND_DIR/data/chain/bitcoin/regtest/admin.macaroon" \
  --lnd.certificate="$LND_DIR/tls.cert" \
  --rpc.host="127.0.0.1" \
  --rpc.port=9002 \
  --rpc.rest.host="127.0.0.1" \
  --rpc.rest.port=9003 \
  --rpc.rest.disable \
  --rpc.tlscert="$BUILD_DIR/boltzd_tls_cert.pem" \
  --rpc.tlskey="$BUILD_DIR/boltzd_tls_key.pem" \
  > $BOLTZD_DIR/stdout.log & echo "$!" > "$BOLTZD_DIR/boltzd.pid"

  # --rpc.adminmacaroonpath=    Path to the admin Macaroon
  # --rpc.readonlymacaroonpath= Path to the readonly macaroon
  # --database.path=            Path to the database file

echo "boltzd has been started!"
