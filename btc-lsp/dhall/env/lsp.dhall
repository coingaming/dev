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

    export LSP_LIBPQ_CONN_STR="postgresql://${Postgres.user}:${Postgres.pass}@${Postgres.host}/${Postgres.database}?sslmode=require"
    export LSP_AES256_INIT_VECTOR="${Lsp.aes256InitVector}"
    export LSP_AES256_SECRET_KEY="${Lsp.aes256SecretKey}"
    export LSP_LND_ENV='{
      "lnd_wallet_password":"${Lnd.walletPass}",
      "lnd_tls_cert":"${Lnd.tlsCert}",
      "lnd_hex_macaroon":"${Lnd.hexMacaroon}",
      "lnd_host":"${lndHost}",
      "lnd_port":"${G.unPort Lnd.grpcPort}"
    }'
    export LSP_GRPC_SERVER_ENV='{
      "port":"${G.unPort Lsp.grpcPort}",
      "sig_verify":true,
      "sig_header_name":"sig-bin",
      "tls_cert":"${Lsp.tlsCert}",
      "tls_key":"${Lsp.tlsKey}"
    }'
    export LSP_BITCOIND_ENV='{
      "host":"${G.unNetworkScheme
                  G.NetworkScheme.Http}://${bitcoindHost}:${G.unPort
                                                              ( Bitcoind.mkRpcPort
                                                                  network
                                                              )}",
      "username":"${Bitcoind.rpcUser}",
      "password":"${Bitcoind.rpcPass}"
    }'
    export LSP_ENDPOINT_PORT="${G.unPort Lsp.grpcPort}"
    export LSP_LOG_ENV="${Lsp.logEnv}"
    export LSP_LOG_FORMAT="${Lsp.logFormat}"
    export LSP_LOG_VERBOSITY="${Lsp.logVerbosity}"
    export LSP_LOG_SEVERITY="${Lsp.logSeverity}"
    export LSP_LND_P2P_PORT="${G.unPort Lnd.p2pPort}"
    export LSP_LND_P2P_HOST="${Lnd.mkHost network}"
    export LSP_ELECTRS_ENV='{
      "host":"electrs",
      "port":"80"
    }'
    ''
