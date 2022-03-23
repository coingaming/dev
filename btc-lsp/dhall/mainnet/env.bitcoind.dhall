let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

let rpcPort = G.unPort (Bitcoind.mkRpcPort network)

let sharedEnv = ../env/bitcoind.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Bitcoind.env.regTest}="0"
    export ${Bitcoind.env.rpcBind}=":${rpcPort}"
    export ${Bitcoind.env.rpcPort}="${rpcPort}"
    export ${Bitcoind.env.testNet}="0"
    ''
