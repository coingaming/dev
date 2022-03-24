let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let owner = G.unOwner G.Owner.Lnd

let bitcoinDefaultChanConfs = Lnd.env.bitcoinDefaultChanConfs

let bitcoinNetwork = Lnd.env.bitcoinNetwork

let bitcoinRpcHost = Lnd.env.bitcoinRpcHost

let bitcoinZmqPubRawBlock = Lnd.env.bitcoinZmqPubRawBlock

let bitcoinZmqPubRawTx = Lnd.env.bitcoinZmqPubRawTx

let bitcoinRpcUser = Lnd.env.bitcoinRpcUser

let bitcoinRpcPass = Lnd.env.bitcoinRpcPass

let lndGrpcPort = Lnd.env.lndGrpcPort

let lndP2pPort = Lnd.env.lndP2pPort

let lndRestPort = Lnd.env.lndRestPort

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    source "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase
                         bitcoinDefaultChanConfs}="${G.mkEnvVar
                                                       bitcoinDefaultChanConfs}" \
      --from-literal=${G.toLowerCase bitcoinNetwork}="${G.mkEnvVar
                                                          bitcoinNetwork}" \
      --from-literal=${G.toLowerCase bitcoinRpcHost}="${G.mkEnvVar
                                                          bitcoinRpcHost}" \
      --from-literal=${G.toLowerCase
                         bitcoinZmqPubRawBlock}="${G.mkEnvVar
                                                     bitcoinZmqPubRawBlock}" \
      --from-literal=${G.toLowerCase
                         bitcoinZmqPubRawTx}="${G.mkEnvVar
                                                  bitcoinZmqPubRawTx}" \
      --from-literal=${G.toLowerCase lndGrpcPort}="${G.mkEnvVar lndGrpcPort}" \
      --from-literal=${G.toLowerCase lndP2pPort}="${G.mkEnvVar lndP2pPort}" \
      --from-literal=${G.toLowerCase lndRestPort}="${G.mkEnvVar
                                                       lndRestPort}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase bitcoinRpcUser}="${G.mkEnvVar
                                                          bitcoinRpcUser}" \
      --from-literal=${G.toLowerCase
                         bitcoinRpcPass}="${G.mkEnvVar bitcoinRpcPass}") || true
    ''
