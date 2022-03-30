let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let Lsp = ../Service/Lsp.dhall

in  ''
    #!/bin/sh

    set -e

    export ${Lsp.env.lspAes256InitVector}="${Lsp.aes256InitVector}"
    export ${Lsp.env.lspAes256SecretKey}="${Lsp.aes256SecretKey}"
    export ${Lsp.env.lspGrpcServerEnv}='{
      "port":${G.unPort Lsp.grpcPort},
      "sig_verify":true,
      "sig_header_name":"sig-bin",
      "tls_cert":"${Lsp.tlsCert}",
      "tls_key":"${Lsp.tlsKey}"
    }'
    export ${Lsp.env.lspEndpointPort}=${G.unPort Lsp.grpcPort}
    export ${Lsp.env.lspLogEnv}="${Lsp.logEnv}"
    export ${Lsp.env.lspLogFormat}="${Lsp.logFormat}"
    export ${Lsp.env.lspLogVerbosity}="${Lsp.logVerbosity}"
    export ${Lsp.env.lspLogSeverity}="${Lsp.logSeverity}"
    export ${Lsp.env.lspLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Lsp.env.lspMinChanCapMsat}="${Natural/show Lnd.minChanSize}"
    export ${Lsp.env.lspElectrsEnv}='{
      "host":"electrs",
      "port":"80"
    }'
    ''
