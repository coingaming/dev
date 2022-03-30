let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let owner = G.unOwner G.Owner.Bitcoind

let configFromEnv = Bitcoind.env.configFromEnv

let disableWallet = Bitcoind.env.disableWallet

let prune = Bitcoind.env.prune

let regTest = Bitcoind.env.regTest

let rpcAllowIp = Bitcoind.env.rpcAllowIp

let rpcBind = Bitcoind.env.rpcBind

let rpcPort = Bitcoind.env.rpcPort

let server = Bitcoind.env.server

let testNet = Bitcoind.env.testNet

let txIndex = Bitcoind.env.txIndex

let zmqPubRawBlock = Bitcoind.env.zmqPubRawBlock

let zmqPubRawTx = Bitcoind.env.zmqPubRawTx

let rpcUser = Bitcoind.env.rpcUser

let rpcPassword = Bitcoind.env.rpcPassword

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase configFromEnv}="${G.mkEnvVar
                                                         configFromEnv}" \
      --from-literal=${G.toLowerCase disableWallet}="${G.mkEnvVar
                                                         disableWallet}" \
      --from-literal=${G.toLowerCase prune}="${G.mkEnvVar prune}" \
      --from-literal=${G.toLowerCase regTest}="${G.mkEnvVar regTest}" \
      --from-literal=${G.toLowerCase rpcAllowIp}="${G.mkEnvVar rpcAllowIp}" \
      --from-literal=${G.toLowerCase rpcBind}="${G.mkEnvVar rpcBind}" \
      --from-literal=${G.toLowerCase rpcPort}="${G.mkEnvVar rpcPort}" \
      --from-literal=${G.toLowerCase server}="${G.mkEnvVar server}" \
      --from-literal=${G.toLowerCase testNet}="${G.mkEnvVar testNet}" \
      --from-literal=${G.toLowerCase txIndex}="${G.mkEnvVar txIndex}" \
      --from-literal=${G.toLowerCase zmqPubRawBlock}="${G.mkEnvVar
                                                          zmqPubRawBlock}" \
      --from-literal=${G.toLowerCase zmqPubRawTx}="${G.mkEnvVar
                                                       zmqPubRawTx}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase rpcUser}="${G.mkEnvVar rpcUser}" \
      --from-literal=${G.toLowerCase rpcPassword}="${G.mkEnvVar
                                                       rpcPassword}") || true
    ''
