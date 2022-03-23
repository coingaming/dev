let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

let rpcPort = G.unPort (Bitcoind.mkRpcPort network)

let sharedEnv = ../env/bitcoind.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export REGTEST="0"
    export RPCBIND=":${rpcPort}"
    export RPCPORT="${rpcPort}"
    export TESTNET="0"
    ''
