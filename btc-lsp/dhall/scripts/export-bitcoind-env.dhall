let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let networkScheme = G.unNetworkScheme G.NetworkScheme.Tcp

in  ''
    export ${Bitcoind.env.configFromEnv}="true"
    export ${Bitcoind.env.disableWallet}="0"
    export ${Bitcoind.env.prune}="0"
    export ${Bitcoind.env.rpcAllowIp}="0.0.0.0/0"
    export ${Bitcoind.env.server}="1"
    export ${Bitcoind.env.txIndex}="1"
    export ${Bitcoind.env.zmqPubRawBlock}="${networkScheme}://0.0.0.0:${G.unPort
                                                                          Bitcoind.zmqPubRawBlockPort}"
    export ${Bitcoind.env.zmqPubRawTx}="${networkScheme}://0.0.0.0:${G.unPort
                                                                       Bitcoind.zmqPubRawTxPort}"
    export ${Bitcoind.env.blockFilterIndex}="1"
    export ${Bitcoind.env.peerBlockFilters}="1"
    ''
