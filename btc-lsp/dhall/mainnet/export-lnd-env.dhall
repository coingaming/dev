let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let sharedEnv = ../env/lnd.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Lnd.env.bitcoinNetwork}="${G.unBitcoinNetwork network}"
    export ${Lnd.env.bitcoinRpcHost}="${bitcoindHost}:${G.unPort
                                                          ( Bitcoind.mkRpcPort
                                                              network
                                                          )}"
    ''
