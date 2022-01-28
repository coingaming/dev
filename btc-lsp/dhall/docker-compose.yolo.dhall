let P = ./Prelude/Import.dhall

let unJson
    : P.JSON.Type → Text
    = λ(x : P.JSON.Type) → Text/replace "\\u0024" "\$" (P.JSON.renderCompact x)

let escape
    : Text → Text
    = λ(x : Text) → Text/replace "\"" "" (unJson (P.JSON.string x))

let mempty = [] : P.Map.Type Text Text

in  { networks.global.external = True
    , version = "3"
    , volumes = { postgres = mempty, bitcoind = mempty, lnd-lsp = mempty }
    , services =
      { postgres =
        { image = "heathmont/postgres:11-alpine-a2e8bbe"
        , hostname = "postgres"
        , environment =
          { POSTGRES_MULTIPLE_DATABASES = "\"btc-lsp\""
          , POSTGRES_PASSWORD = "developer"
          , POSTGRES_USER = "btc-lsp"
          }
        , volumes = [ "postgres:/var/lib/postgresql/data" ]
        , networks.global = mempty
        }
      , bitcoind =
        { image = "heathmont/bitcoind:v1.0.9"
        , hostname = "bitcoind"
        , environment =
          { CONFIG_FROM_ENV = "true"
          , DISABLEWALLET = "0"
          , PRUNE = "0"
          , REGTEST = "1"
          , RPCALLOWIP = "0.0.0.0/0"
          , RPCBIND = ":18332"
          , RPCPASSWORD = "developer"
          , RPCPORT = "18332"
          , RPCUSER = "bitcoinrpc"
          , SERVER = "1"
          , TESTNET = "0"
          , TXINDEX = "1"
          , ZMQPUBRAWBLOCK = "tcp://0.0.0.0:39703"
          , ZMQPUBRAWTX = "tcp://0.0.0.0:39704"
          }
        , volumes = [ "bitcoind:/bitcoin/.bitcoin" ]
        , networks.global = mempty
        }
      , lnd-lsp =
        { image = "lightninglabs/lnd:v0.13.1-beta.rc2"
        , hostname = "lnd-lsp"
        , command =
          [ "-c"
          , "lnd --bitcoin.active --bitcoin.\$\$BITCOIN_NETWORK --bitcoin.node=bitcoind --bitcoin.defaultchanconfs=\$\$BITCOIN_DEFAULTCHANCONFS --bitcoind.rpchost=\$\$BITCOIN_RPCHOST --bitcoind.rpcuser=\$\$BITCOIN_RPCUSER --bitcoind.rpcpass=\$\$BITCOIN_RPCPASS --bitcoind.zmqpubrawblock=\$\$BITCOIN_ZMQPUBRAWBLOCK --bitcoind.zmqpubrawtx=\$\$BITCOIN_ZMQPUBRAWTX --tlsextradomain=\$\$TLS_EXTRADOMAIN --restlisten=0.0.0.0:\$\$LND_REST_PORT --rpclisten=0.0.0.0:\$\$LND_GRPC_PORT --listen=0.0.0.0:\$\$LND_P2P_PORT --maxpendingchannels=100"
          ]
        , entrypoint = [ "sh" ]
        , environment =
          { BITCOIN_DEFAULTCHANCONFS = "1"
          , BITCOIN_NETWORK = "regtest"
          , BITCOIN_RPCHOST = "bitcoind"
          , BITCOIN_RPCPASS = "developer"
          , BITCOIN_RPCUSER = "bitcoinrpc"
          , BITCOIN_ZMQPUBRAWBLOCK = "tcp://bitcoind:39703"
          , BITCOIN_ZMQPUBRAWTX = "tcp://bitcoind:39704"
          , LND_GRPC_PORT = "10009"
          , LND_P2P_PORT = "9735"
          , LND_REST_PORT = "8080"
          , TLS_EXTRADOMAIN = "lnd-lsp"
          }
        , volumes = [ "lnd-lsp:/root/.lnd" ]
        , networks.global = mempty
        }
      , btc-lsp =
        { image = ../build/docker-image-btc-lsp.txt as Text
        , hostname = "btc-lsp"
        , ports = [ "8443:8443/tcp" ]
        , environment =
          { -- General
            LSP_LIBPQ_CONN_STR =
              "postgresql://btc-lsp:developer@postgres/btc-lsp"
          , LSP_ENDPOINT_PORT = "8443"
          , -- Logging
            LSP_LOG_ENV = "test"
          , LSP_LOG_FORMAT = "Bracket"
          , LSP_LOG_VERBOSITY = "V3"
          , LSP_LOG_SEVERITY = "InfoS"
          , -- Encryption
            LSP_AES256_SECRET_KEY = "y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN"
          , LSP_AES256_INIT_VECTOR = "dRgUkXp2s5v8y/B?"
          , -- Lnd
            LSP_LND_ENV =
              ''
              {
                "lnd_wallet_password":"developer",
                "lnd_tls_cert":"${  escape
                                      ../build/swarm/lnd-lsp/tls.cert as Text
                                  ? "TODO"}",
                "lnd_hex_macaroon":"${  ../build/swarm/lnd-lsp/macaroon-regtest.hex as Text
                                      ? "TODO"}",
                "lnd_host":"lnd-lsp",
                "lnd_port":10009,
                "lnd_cipher_seed_mnemonic":[
                   "absent",
                   "betray",
                   "direct",
                   "scheme",
                   "sunset",
                   "mechanic",
                   "exhaust",
                   "suggest",
                   "boy",
                   "arena",
                   "sketch",
                   "bone",
                   "news",
                   "south",
                   "way",
                   "survey",
                   "clip",
                   "dutch",
                   "depart",
                   "green",
                   "furnace",
                   "wire",
                   "wave",
                   "fall"
                ]
              }
              ''
          , -- Grpc
            LSP_GRPC_SERVER_ENV =
              ''
              {
                "port":8443,
                "prv_key":"${escape ../build/esdsa.prv as Text}",
                "pub_key":"${escape ../build/esdsa.pub as Text}",
                "sig_header_name":"compact-2xsha256-sig",
                "tls_cert":"${escape ../build/btc_lsp_tls_cert.pem as Text}",
                "tls_key":"${escape ../build/btc_lsp_tls_key.pem as Text}"
              }
              ''
          }
        , networks.global = mempty
        }
      }
    }
