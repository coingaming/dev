let Integration = ../Service/Integration.dhall

let Lsp = ../Service/Lsp.dhall

let G = ../Global.dhall

let lndHost = G.unOwner G.Owner.Lnd

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.RegTest

let Lnd = ../Service/Lnd.dhall

let Postgres = ../Service/Postgres.dhall

in  ''
    export ${Integration.env.integrationGrpcClientEnv}='{
      "host":"${lndHost}",
      "port":${G.unPort Lsp.grpcPort},
      "sig_header_name":"sig-bin",
      "compress_mode":"Compressed"
    }'
    export ${Integration.env.integrationBitcoindEnv}='{
      "host":"${G.unNetworkScheme
                  G.NetworkScheme.Http}://${bitcoindHost}:${G.unPort
                                                              ( Bitcoind.mkRpcPort
                                                                  network
                                                              )}",
      "username":"${Bitcoind.rpcUser}",
      "password":"${Bitcoind.rpcPass}"
    }'
    export ${Integration.env.integrationGrpcServerEnv}='{
      "port":${G.unPort Lsp.grpcPort},
      "sig_verify":true,
      "sig_header_name":"sig-bin",
      "tls_cert":"${Lsp.tlsCert}",
      "tls_key":"${Lsp.tlsKey}"
    }'
    export ${Integration.env.integrationLndEnv}='{
      "lnd_wallet_password":"${Lnd.walletPass}",
      "lnd_tls_cert":"${G.escape Lnd.tlsCert}",
      "lnd_hex_macaroon":"${Lnd.hexMacaroon}",
      "lnd_host":"${lndHost}",
      "lnd_port":${G.unPort Lnd.grpcPort}
    }'
    export ${Integration.env.integrationElectrsEnv}='{
      "host":"electrs",
      "port":"80"
    }'
    export ${Integration.env.integrationLibpqConnStr}="postgresql://${Postgres.user}:${Postgres.password}@${Postgres.host}/${Postgres.database}"
    export ${Integration.env.integrationLndP2pHost}="${Lnd.mkHost network}"
    export ${Integration.env.integrationLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Integration.env.integrationLogEnv}="${Lsp.logEnv}"
    export ${Integration.env.integrationLogFormat}="${Lsp.logFormat}"
    export ${Integration.env.integrationLogSeverity}="${Lsp.logSeverity}"
    export ${Integration.env.integrationLogVerbosity}="${Lsp.logVerbosity}"
    export ${Integration.env.integrationMinChanCapMsat}="20000000"

    ''
