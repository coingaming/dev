#!/bin/sh

#
# Bitcoind
#

. nix/ns-export-test-envs.sh

echo "starting bitcoind..."
bitcoind -fallbackfee=0.0002 -datadir=$BTCD_DIR &
alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18443"
bitcoin-cli getblockchaininfo
echo "bitcoind has been started!"

echo "starting bitcoind2..."
bitcoind -port=21000 -rpcport=21001 -fallbackfee=0.0002 -datadir=$BTCD2_DIR &
alias bitcoin-cli-2="bitcoin-cli -rpcwait -datadir=$BTCD2_DIR -rpcport=21001"
bitcoin-cli-2 getblockchaininfo
echo "bitcoind2 has been started!"

echo "add nodes..."
bitcoin-cli addnode "127.0.0.1:21000" "add"
echo "nodes are connected"



