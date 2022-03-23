let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let Lnd = ../Service/Lnd.dhall

let Lsp = ../Service/Lsp.dhall

let Postgres = ../Service/Postgres.dhall

let network = G.BitcoinNetwork.RegTest

let bitcoindHost = G.unOwner G.Owner.Bitcoind

let lndHost = G.unOwner G.Owner.Lnd

in  ''
    #!/bin/sh

    set -e

    export ${Lsp.env.lspLibpqConnStr}="postgresql://${Postgres.user}:${Postgres.pass}@${Postgres.host}/${Postgres.database}?sslmode=require"
    export ${Lsp.env.lspAes256InitVector}="${Lsp.aes256InitVector}"
    export ${Lsp.env.lspAes256SecretKey}="${Lsp.aes256SecretKey}"
    export ${Lsp.env.lspLndEnv}='{
      "lnd_wallet_password":"${Lnd.walletPass}",
      "lnd_tls_cert":"${Lnd.tlsCert}",
      "lnd_hex_macaroon":"${Lnd.hexMacaroon}",
      "lnd_host":"${lndHost}",
      "lnd_port":"${G.unPort Lnd.grpcPort}"
    }'
    export ${Lsp.env.lspGrpcServerEnv}='{
      "port":"${G.unPort Lsp.grpcPort}",
      "sig_verify":true,
      "sig_header_name":"sig-bin",
      "tls_cert":"${Lsp.tlsCert}",
      "tls_key":"${Lsp.tlsKey}"
    }'
    export ${Lsp.env.lspBitcoindEnv}='{
      "host":"${G.unNetworkScheme
                  G.NetworkScheme.Http}://${bitcoindHost}:${G.unPort
                                                              ( Bitcoind.mkRpcPort
                                                                  network
                                                              )}",
      "username":"${Bitcoind.rpcUser}",
      "password":"${Bitcoind.rpcPass}"
    }'
    export ${Lsp.env.lspEndpointPort}="${G.unPort Lsp.grpcPort}"
    export ${Lsp.env.lspLogEnv}="${Lsp.logEnv}"
    export ${Lsp.env.lspLogFormat}="${Lsp.logFormat}"
    export ${Lsp.env.lspLogVerbosity}="${Lsp.logVerbosity}"
    export ${Lsp.env.lspLogSeverity}="${Lsp.logSeverity}"
    export ${Lsp.env.lspLndP2pPort}="${G.unPort Lnd.p2pPort}"
    export ${Lsp.env.lspLndP2pHost}="${Lnd.mkHost network}"
    export ${Lsp.env.lspElectrsEnv}='{
      "host":"electrs",
      "port":"80"
    }'
    ''
