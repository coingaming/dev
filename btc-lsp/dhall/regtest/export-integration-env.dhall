let Integration = ../Service/Integration.dhall

let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let network = G.BitcoinNetwork.RegTest

let Lnd = ../Service/Lnd.dhall

let Lsp = ../Service/Lsp.dhall

let Postgres = ../Service/Postgres.dhall

in  ''
    export ${Integration.env.integrationGrpcClientEnv}='${P.JSON.render
                                                            Lsp.mkLspGrpcClientEnv}'
    export ${Lsp.env.lspBitcoindEnv}='${P.JSON.render
                                          (Lsp.mkLspBitcoindEnv network)}'
    export ${Lsp.env.lspGrpcServerEnv}='${P.JSON.render Lsp.mkLspGrpcServerEnv}'
    export ${Lsp.env.lspLndEnv}='${P.JSON.render
                                     (Lsp.mkLndEnv network G.Owner.Lnd)}'
    export ${Integration.env.integrationLndEnv2}='${P.JSON.render
                                                      ( Lsp.mkLndEnv
                                                          network
                                                          G.Owner.LndBob
                                                      )}'
    export ${Lsp.env.lspLibpqConnStr}='${Postgres.mkConnStr network}'
    export ${Lsp.env.lspLndP2pHost}="${Lnd.mkDomain network}"
    export ${Lsp.env.lspLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Lsp.env.lspLogEnv}="${Lsp.logEnv}"
    export ${Lsp.env.lspLogFormat}="${Lsp.logFormat}"
    export ${Lsp.env.lspLogSeverity}="${Lsp.logSeverity}"
    export ${Lsp.env.lspLogVerbosity}="${Lsp.logVerbosity}"
    export ${Lsp.env.lspMinChanCapMsat}="20000000"
    ''
