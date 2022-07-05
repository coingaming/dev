#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
SHELL_DIR="$THIS_DIR/../build/shell"

. "$THIS_DIR/ns-export-test-envs.sh"

bitcoin_pid=`cat $BTCD_DIR/regtest/bitcoind.pid`
bitcoin2_pid=`cat $BTCD2_DIR/regtest/bitcoind.pid`
lnd_lsp_pid=`cat $LND_LSP_DIR/lnd.pid`
lnd_alice_pid=`cat $LND_ALICE_DIR/lnd.pid`
lnd_bob_pid=`cat $LND_BOB_DIR/lnd.pid`

lncli-lsp stop
lncli-alice stop
lncli-bob stop
timeout 5 bitcoin-cli stop
timeout 5 bitcoin-cli-2 stop
timeout 5 pg_ctl -D $PGDATA stop
kill -9 "$lnd_lsp_pid" && true
kill -9 "$lnd_alice_pid" && true
kill -9 "$lnd_bob_pid" && true
kill -9 "$bitcoin_pid" && true
kill -9 "$bitcoin2_pid" && true
