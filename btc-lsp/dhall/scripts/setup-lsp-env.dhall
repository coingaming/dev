let G = ../Global.dhall

let Lsp = ../Service/Lsp.dhall

let owner = G.unOwner G.Owner.Lsp

let lspEndpointPort = Lsp.env.lspEndpointPort

let lspLogEnv = Lsp.env.lspLogEnv

let lspLogFormat = Lsp.env.lspLogFormat

let lspLogVerbosity = Lsp.env.lspLogVerbosity

let lspLogSeverity = Lsp.env.lspLogSeverity

let lspLndP2pPort = Lsp.env.lspLndP2pPort

let lspLndP2pHost = Lsp.env.lspLndP2pHost

let lspElectrsEnv = Lsp.env.lspElectrsEnv

let lspLibpqConnStr = Lsp.env.lspLibpqConnStr

let lspAes256InitVector = Lsp.env.lspAes256InitVector

let lspAes256SecretKey = Lsp.env.lspAes256SecretKey

let lspLndEnv = Lsp.env.lspLndEnv

let lspGrpcServerEnv = Lsp.env.lspGrpcServerEnv

let lspBitcoindEnv = Lsp.env.lspBitcoindEnv

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    source "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase lspEndpointPort}="${G.mkEnvVar
                                                           lspEndpointPort}" \
      --from-literal=${G.toLowerCase lspLogEnv}="${G.mkEnvVar lspLogEnv}" \
      --from-literal=${G.toLowerCase lspLogFormat}="${G.mkEnvVar
                                                        lspLogFormat}" \
      --from-literal=${G.toLowerCase lspLogVerbosity}="${G.mkEnvVar
                                                           lspLogVerbosity}" \
      --from-literal=${G.toLowerCase lspLogSeverity}="${G.mkEnvVar
                                                          lspLogSeverity}" \
      --from-literal=${G.toLowerCase lspLndP2pPort}="${G.mkEnvVar
                                                         lspLndP2pPort}" \
      --from-literal=${G.toLowerCase lspLndP2pHost}="${G.mkEnvVar
                                                         lspLndP2pHost}" \
      --from-literal=${G.toLowerCase
                         lspElectrsEnv}="${G.mkEnvVar lspElectrsEnv}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase lspLibpqConnStr}="${G.mkEnvVar
                                                           lspLibpqConnStr}" \
      --from-literal=${G.toLowerCase
                         lspAes256InitVector}="${G.mkEnvVar
                                                   lspAes256InitVector}" \
      --from-literal=${G.toLowerCase
                         lspAes256SecretKey}="${G.mkEnvVar
                                                  lspAes256SecretKey}" \
      --from-literal=${G.toLowerCase lspLndEnv}="${G.mkEnvVar lspLndEnv}" \
      --from-literal=${G.toLowerCase lspGrpcServerEnv}="${G.mkEnvVar
                                                            lspGrpcServerEnv}" \
      --from-literal=${G.toLowerCase
                         lspBitcoindEnv}="${G.mkEnvVar lspBitcoindEnv}") || true
    ''
