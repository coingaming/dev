let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let sharedEnv = ../scripts/export-lnd-env.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Lnd.env.bitcoinNetwork}="${G.unBitcoinNetwork network}"
    export ${Lnd.env.bitcoinRpcHost}="${bitcoindHost}:${G.unPort
                                                          ( Bitcoind.mkRpcPort
                                                              network
                                                          )}"
    export ${Lnd.env.lndWalletPass}="${Lnd.mkWalletPass network}"
    export ${Lnd.env.bitcoinRpcUser}="${Bitcoind.mkRpcUser network}"
    export ${Lnd.env.bitcoinRpcPass}="${Bitcoind.mkRpcPass network}"
    ''
