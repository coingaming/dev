#!/bin/sh

#
# Bitcoind
#

set -m

ROOT_DIR="$(pwd)"
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"
BTCD_DIR="$SHELL_DIR/bitcoind"
#. nix/ns-export-test-envs.sh

echo "starting bitcoind..."
bitcoind -datadir=$BTCD_DIR &
alias bitcoin-cli="bitcoin-cli -rpcwait -datadir=$BTCD_DIR -rpcport=18444 -regtest -rpcuser=bitcoinrpc -rpcpassword=bitcoinrpcpassword"
bitcoin-cli createwallet "testwallet"
bitcoin-cli generatetoaddress 1 "$(bitcoin-cli getnewaddress)"
bitcoin-cli getblockchaininfo
echo "bitcoind has been started!"


