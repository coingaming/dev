let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.RegTest

let rpcPort = G.unPort (Bitcoind.mkRpcPort network)

let networkScheme = G.unNetworkScheme G.NetworkScheme.Tcp

in  ''
    #!/bin/sh

    set -e

    export CONFIG_FROM_ENV="true"
    export DISABLEWALLET="0"
    export PRUNE="0"
    export REGTEST="1"
    export RPCALLOWIP="0.0.0.0/0"
    export RPCBIND=":${rpcPort}"
    export RPCPORT="${rpcPort}"
    export SERVER="1"
    export TESTNET="0"
    export TXINDEX="1"
    export ZMQPUBRAWBLOCK="${networkScheme}://0.0.0.0:${G.unPort
                                                          Bitcoind.zmqPubRawBlockPort}"
    export ZMQPUBRAWTX="${networkScheme}://0.0.0.0:${G.unPort
                                                       Bitcoind.zmqPubRawTxPort}"
    export RPCUSER="${Bitcoind.rpcUser}"
    export RPCPASSWORD="${Bitcoind.rpcPass}"

    ''
