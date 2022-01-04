#!/bin/sh

#
# Bitcoind
#

. nix/export-test-envs.sh

echo "starting bitcoind..."
bitcoind -datadir=$BTCD_DIR &
alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18443"
bitcoin-cli generatetoaddress 1 "$(bitcoin-cli getnewaddress)"
bitcoin-cli getblockchaininfo
echo "bitcoind has been started!"


