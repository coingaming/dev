#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/export-test-envs.sh"

echo "==> resetting test data..."
rm -rf $LND_LSP_DIR/data
rm -rf $LND_ALICE_DIR/data
rm -rf $LND_BOB_DIR/data
rm -rf $BTCD_DIR/regtest
rm -rf $PGDATA
echo "==> test data has been reset!"
