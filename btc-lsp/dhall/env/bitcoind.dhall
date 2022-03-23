let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let networkScheme = G.unNetworkScheme G.NetworkScheme.Tcp

in  ''
    export CONFIG_FROM_ENV="true"
    export DISABLEWALLET="0"
    export PRUNE="0"
    export RPCALLOWIP="0.0.0.0/0"
    export SERVER="1"
    export TXINDEX="1"
    export ZMQPUBRAWBLOCK="${networkScheme}://0.0.0.0:${G.unPort
                                                          Bitcoind.zmqPubRawBlockPort}"
    export ZMQPUBRAWTX="${networkScheme}://0.0.0.0:${G.unPort
                                                       Bitcoind.zmqPubRawTxPort}"
    export RPCUSER="${Bitcoind.rpcUser}"
    export RPCPASSWORD="${Bitcoind.rpcPass}"
    ''
