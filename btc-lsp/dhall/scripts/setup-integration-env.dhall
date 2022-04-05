let G = ../Global.dhall

let Integration = ../Service/Integration.dhall

let owner = G.unOwner G.Owner.Integration

let integrationGrpcClientEnv = Integration.env.integrationGrpcClientEnv

let integrationBitcoindEnv = Integration.env.integrationBitcoindEnv

let integrationGrpcServerEnv = Integration.env.integrationGrpcServerEnv

let integrationLndEnv = Integration.env.integrationLndEnv

let integrationElectrsEnv = Integration.env.integrationElectrsEnv

let integrationLibpqConnStr = Integration.env.integrationLibpqConnStr

let integrationLndP2pHost = Integration.env.integrationLndP2pHost

let integrationLndP2pPort = Integration.env.integrationLndP2pPort

let integrationLogEnv = Integration.env.integrationLogEnv

let integrationLogFormat = Integration.env.integrationLogFormat

let integrationLogSeverity = Integration.env.integrationLogSeverity

let integrationLogVerbosity = Integration.env.integrationLogVerbosity

let integrationMinChanCapMsat = Integration.env.integrationMinChanCapMsat

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    source "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase
                         integrationGrpcClientEnv}="${G.mkEnvVar
                                                        integrationGrpcClientEnv}" \
      --from-literal=${G.toLowerCase
                         integrationElectrsEnv}="${G.mkEnvVar
                                                     integrationElectrsEnv}" \
      --from-literal=${G.toLowerCase
                         integrationLndP2pHost}="${G.mkEnvVar
                                                     integrationLndP2pHost}" \
      --from-literal=${G.toLowerCase
                         integrationLndP2pPort}="${G.mkEnvVar
                                                     integrationLndP2pPort}" \
      --from-literal=${G.toLowerCase
                         integrationLogEnv}="${G.mkEnvVar integrationLogEnv}" \
      --from-literal=${G.toLowerCase
                         integrationLogFormat}="${G.mkEnvVar
                                                    integrationLogFormat}" \
      --from-literal=${G.toLowerCase
                         integrationLogSeverity}="${G.mkEnvVar
                                                      integrationLogSeverity}" \
      --from-literal=${G.toLowerCase
                         integrationLogVerbosity}="${G.mkEnvVar
                                                       integrationLogVerbosity}" \
      --from-literal=${G.toLowerCase
                         integrationMinChanCapMsat}="${G.mkEnvVar
                                                         integrationMinChanCapMsat}") || true
    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase
                         integrationGrpcServerEnv}="${G.mkEnvVar
                                                        integrationGrpcServerEnv}" \
      --from-literal=${G.toLowerCase
                         integrationLndEnv}="${G.mkEnvVar integrationLndEnv}" \
      --from-literal=${G.toLowerCase
                         integrationLibpqConnStr}="${G.mkEnvVar
                                                       integrationLibpqConnStr}" \
      --from-literal=${G.toLowerCase
                         integrationBitcoindEnv}="${G.mkEnvVar
                                                      integrationBitcoindEnv}") || true
    ''
