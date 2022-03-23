let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.TestNet

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let sharedEnv = ../env/lnd.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export BITCOIN_NETWORK="${G.unBitcoinNetwork network}"
    export BITCOIN_RPCHOST="${bitcoindHost}:${G.unPort
                                                (Bitcoind.mkRpcPort network)}"
    ''
