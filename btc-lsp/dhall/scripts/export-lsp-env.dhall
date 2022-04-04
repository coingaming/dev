let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let Lsp = ../Service/Lsp.dhall

in  ''
    export ${Lsp.env.lspEndpointPort}=${G.unPort Lsp.grpcPort}
    export ${Lsp.env.lspLogEnv}="${Lsp.logEnv}"
    export ${Lsp.env.lspLogFormat}="${Lsp.logFormat}"
    export ${Lsp.env.lspLogVerbosity}="${Lsp.logVerbosity}"
    export ${Lsp.env.lspLogSeverity}="${Lsp.logSeverity}"
    export ${Lsp.env.lspLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Lsp.env.lspMinChanCapMsat}="${Natural/show Lnd.minChanSize}"
    export ${Lsp.env.lspGrpcServerEnv}='${Lsp.mkLspGrpcServerEnv}'
    ''
