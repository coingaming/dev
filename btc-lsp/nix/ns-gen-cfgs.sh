#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"
SHELL_DIR="$BUILD_DIR/shell"

(
  set -- lsp alice bob
  for i in $(seq 1 3); do
    OWNER=$(eval "echo \$$i")
    SERVICE_DIR="$SHELL_DIR/lnd-$OWNER"
    echo "==> Generating $SERVICE_DIR"
    mkdir -p "$SERVICE_DIR"
    echo "
[Bitcoin]

bitcoin.active=1
bitcoin.regtest=1
bitcoin.node=bitcoind

[Bitcoind]

bitcoind.rpchost=localhost
bitcoind.rpcuser=developer
bitcoind.rpcpass=developer
bitcoind.zmqpubrawblock=tcp://127.0.0.1:28332
bitcoind.zmqpubrawtx=tcp://127.0.0.1:28333

[protocol]

protocol.wumbo-channels=true

[Application Options]

listen=0.0.0.0:$((9735 + i))
rpclisten=localhost:$((10009 + i))
restlisten=0.0.0.0:$((8080 + i))
debuglevel=warn,PEER=warn" > "$SERVICE_DIR/lnd.conf"
  done
)

(
  SERVICE_DIR="$SHELL_DIR/bitcoind"
  echo "==> Generating $SERVICE_DIR"
  mkdir -p "$SERVICE_DIR"
  echo "
regtest=1
daemon=1
txindex=1
mintxfee=0.00000001

rpcuser=developer
rpcpassword=developer

zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333

fallbackfee=0.00000001
server=1
rest=1" > "$SERVICE_DIR/bitcoin.conf"
)

(
  SERVICE_DIR2="$SHELL_DIR/bitcoind2"
  echo "==> Generating $SERVICE_DIR2"
  mkdir -p "$SERVICE_DIR2"
  echo "
regtest=1
daemon=1
txindex=1

rpcuser=developer
rpcpassword=developer

zmqpubrawblock=tcp://127.0.0.1:29332
zmqpubrawtx=tcp://127.0.0.1:29333

server=1
rest=1" > "$SERVICE_DIR2/bitcoin.conf"
)
echo "==> Generated cfgs"
