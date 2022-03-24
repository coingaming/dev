let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let networkScheme = G.unNetworkScheme G.NetworkScheme.Tcp

in  ''
    export ${Lnd.env.bitcoinDefaultChanConfs}="1"
    export ${Lnd.env.bitcoinRpcUser}="${Bitcoind.rpcUser}"
    export ${Lnd.env.bitcoinRpcPass}="${Bitcoind.rpcPass}"
    export ${Lnd.env.bitcoinZmqPubRawBlock}="${networkScheme}://${bitcoindHost}:${G.unPort
                                                                                    Bitcoind.zmqPubRawBlockPort}"
    export ${Lnd.env.bitcoinZmqPubRawTx}="${networkScheme}://${bitcoindHost}:${G.unPort
                                                                                 Bitcoind.zmqPubRawTxPort}"
    export ${Lnd.env.lndGrpcPort}="${G.unPort Lnd.grpcPort}"
    export ${Lnd.env.lndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Lnd.env.lndRestPort}="${G.unPort Lnd.restPort}"
    export ${Lnd.env.lndWalletPass}="${Lnd.walletPass}"
    ''
