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

let lspMinChanCapMsat = Lsp.env.lspMinChanCapMsat

let lspLibpqConnStr = Lsp.env.lspLibpqConnStr

let lspLndEnv = Lsp.env.lspLndEnv

let lspBitcoindEnv = Lsp.env.lspBitcoindEnv

let lspGrpcServerEnv = Lsp.env.lspGrpcServerEnv

let lspMsatPerByte = Lsp.env.lspMsatPerByte

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    . "$THIS_DIR/export-${owner}-env.sh"

    echo "==> Setting up env for ${owner}"

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
                         lspMinChanCapMsat}="${G.mkEnvVar lspMinChanCapMsat}" \
      --from-literal=${G.toLowerCase
                         lspMsatPerByte}="${G.mkEnvVar lspMsatPerByte}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase lspLibpqConnStr}="${G.mkEnvVar
                                                           lspLibpqConnStr}" \
      --from-literal=${G.toLowerCase lspLndEnv}="${G.mkEnvVar lspLndEnv}" \
      --from-literal=${G.toLowerCase lspGrpcServerEnv}="${G.mkEnvVar
                                                            lspGrpcServerEnv}" \
      --from-literal=${G.toLowerCase
                         lspBitcoindEnv}="${G.mkEnvVar lspBitcoindEnv}") || true
    ''
