#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ELECTRS_DIR="$THIS_DIR/../.electrs"

. ./nix/export-test-envs.sh

bitcoin_pid=`cat $BTCD_DIR/regtest/bitcoind.pid`
merchant_lnd_pid=`cat $LND_MERCHANT_DIR/lnd.pid`
payments_lnd_pid=`cat $LND_PAYMENTS_DIR/lnd.pid`
electrs_pid=`cat $ELECTRS_DIR/electrs.pid`

kill -9 "$electrs_pid" && true
lncli-merchant stop
lncli-payments stop
timeout 5 bitcoin-cli stop
timeout 5 pg_ctl -D $PGDATA stop
kill -9 "$merchant_lnd_pid" && true
kill -9 "$payments_lnd_pid" && true
kill -9 "$bitcoin_pid" && true
