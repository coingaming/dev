let Integration = ../Service/Integration.dhall

let P = ../Prelude/Import.dhall

let Lsp = ../Service/Lsp.dhall

let G = ../Global.dhall

let network = G.BitcoinNetwork.RegTest

let Lnd = ../Service/Lnd.dhall

let Postgres = ../Service/Postgres.dhall

in  ''
    export ${Integration.env.integrationGrpcClientEnv}='${P.JSON.render
                                                            Lsp.mkLspGrpcClientEnv}'
    export ${Integration.env.integrationBitcoindEnv}='${Integration.mkIntegrationBitcoindEnv
                                                          network}'
    export ${Integration.env.integrationGrpcServerEnv}='${Integration.mkIntegrationGrpcServerEnv}'
    export ${Integration.env.integrationLndEnv}='${Integration.mkIntegrationLndEnv
                                                     network}'
    export ${Integration.env.integrationLndEnv2}='${Integration.mkIntegrationLndEnv
                                                      network}'
    export ${Integration.env.integrationElectrsEnv}='{
      "host":"electrs",
      "port":"80"
    }'
    export ${Integration.env.integrationLibpqConnStr}='${Postgres.mkConnStr
                                                           network}'
    export ${Integration.env.integrationLndP2pHost}="${Lnd.mkDomain network}"
    export ${Integration.env.integrationLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Integration.env.integrationLogEnv}="${Lsp.logEnv}"
    export ${Integration.env.integrationLogFormat}="${Lsp.logFormat}"
    export ${Integration.env.integrationLogSeverity}="${Lsp.logSeverity}"
    export ${Integration.env.integrationLogVerbosity}="${Lsp.logVerbosity}"
    export ${Integration.env.integrationMinChanCapMsat}="20000000"
    ''
