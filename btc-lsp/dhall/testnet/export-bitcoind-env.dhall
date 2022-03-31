let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.TestNet

let rpcPort = G.unPort (Bitcoind.mkRpcPort network)

let sharedEnv = ../scripts/export-bitcoind-env.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Bitcoind.env.regTest}="0"
    export ${Bitcoind.env.rpcBind}=":${rpcPort}"
    export ${Bitcoind.env.rpcPort}="${rpcPort}"
    export ${Bitcoind.env.testNet}="1"
    export ${Bitcoind.env.rpcUser}="${Bitcoind.mkRpcUser network}"
    export ${Bitcoind.env.rpcPassword}="${Bitcoind.mkRpcPass network}"
    ''
