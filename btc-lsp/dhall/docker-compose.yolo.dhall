let P = ./Prelude/Import.dhall

let unJson
    : P.JSON.Type → Text
    = λ(x : P.JSON.Type) → Text/replace "\\u0024" "\$" (P.JSON.renderCompact x)

let escape
    : Text → Text
    = λ(x : Text) → Text/replace "\"" "" (unJson (P.JSON.string x))

let mempty = [] : P.Map.Type Text Text

let todo
    : Text
    = "TODO"

let mkLnd =
      λ(owner : Text) →
        { image = "lightninglabs/lnd:v0.13.1-beta.rc2"
        , hostname = "lnd-${owner}"
        , ports = [ "9735:9735/tcp" ]
        , command =
          [ "-c"
          , "lnd --bitcoin.active --bitcoin.\$\$BITCOIN_NETWORK --bitcoin.node=bitcoind --bitcoin.defaultchanconfs=\$\$BITCOIN_DEFAULTCHANCONFS --bitcoind.rpchost=\$\$BITCOIN_RPCHOST --bitcoind.rpcuser=\$\$BITCOIN_RPCUSER --bitcoind.rpcpass=\$\$BITCOIN_RPCPASS --bitcoind.zmqpubrawblock=\$\$BITCOIN_ZMQPUBRAWBLOCK --bitcoind.zmqpubrawtx=\$\$BITCOIN_ZMQPUBRAWTX --tlsextradomain=\$\$TLS_EXTRADOMAIN --restlisten=0.0.0.0:\$\$LND_REST_PORT --rpclisten=0.0.0.0:\$\$LND_GRPC_PORT --listen=0.0.0.0:\$\$LND_P2P_PORT --maxpendingchannels=100"
          ]
        , entrypoint = [ "sh" ]
        , environment =
          { BITCOIN_DEFAULTCHANCONFS = "1"
          , BITCOIN_NETWORK = "regtest"
          , BITCOIN_RPCHOST = "bitcoind:80"
          , BITCOIN_RPCPASS = "developer"
          , BITCOIN_RPCUSER = "bitcoinrpc"
          , BITCOIN_ZMQPUBRAWBLOCK = "tcp://bitcoind:39703"
          , BITCOIN_ZMQPUBRAWTX = "tcp://bitcoind:39704"
          , LND_GRPC_PORT = "10009"
          , LND_P2P_PORT = "9735"
          , LND_REST_PORT = "80"
          , TLS_EXTRADOMAIN = "lnd-${owner}"
          }
        , volumes = [ "lnd-${owner}:/root/.lnd" ]
        , networks.global = mempty
        }

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
        , ports = [ "39703:39703/tcp", "39704:39704/tcp" ]
        , environment =
          { CONFIG_FROM_ENV = "true"
          , DISABLEWALLET = "0"
          , PRUNE = "0"
          , REGTEST = "1"
          , RPCALLOWIP = "0.0.0.0/0"
          , RPCBIND = ":80"
          , RPCPASSWORD = "developer"
          , RPCPORT = "80"
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
      , lnd-lsp = mkLnd "lsp"
      , rtl =
        { environment =
          { RTL_CONFIG_JSON =
              ''
              {
                "SSO":{
                  "logoutRedirectLink": "",
                  "rtlCookiePath": "",
                  "rtlSSO": 0
                },
                "defaultNodeIndex": 1,
                "multiPass": "developer",
                "nodes": [],
                "port": "80"
              }
              ''
          , RTL_CONFIG_NODES_JSON =
              ''
              [
                {
                  "hexMacaroon": "${  ../build/swarm/lnd-lsp/macaroon-regtest.hex as Text
                                    ? todo}",
                  "index": 1,
                  "lnServerUrl": "https://lnd-lsp:80"
                }
              ]
              ''
          }
        , hostname = "rtl"
        , image = "heathmont/rtl:9c8d7d6"
        , networks.global = mempty
        }
      , btc-lsp =
        { image = ../build/docker-image-btc-lsp.txt as Text
        , hostname = "btc-lsp"
        , ports = [ "8443:443/tcp" ]
        , environment =
          { -- General
            LSP_LIBPQ_CONN_STR =
              "postgresql://btc-lsp:developer@postgres/btc-lsp"
          , LSP_ENDPOINT_PORT = "443"
          , -- Logging
            LSP_LOG_ENV = "test"
          , LSP_LOG_FORMAT = "Bracket"
          , LSP_LOG_VERBOSITY = "V3"
          , LSP_LOG_SEVERITY = "DebugS"
          , -- Encryption
            LSP_AES256_SECRET_KEY = "y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN"
          , LSP_AES256_INIT_VECTOR = "dRgUkXp2s5v8y/B?"
          , -- Rpc
            LSP_LND_ENV =
              ''
              {
                "lnd_wallet_password":"developer",
                "lnd_tls_cert":"${  escape
                                      ../build/swarm/lnd-lsp/tls.cert as Text
                                  ? todo}",
                "lnd_hex_macaroon":"${  ../build/swarm/lnd-lsp/macaroon-regtest.hex as Text
                                      ? todo}",
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
          , LSP_GRPC_SERVER_ENV =
              ''
              {
                "port":443,
                "sig_verify":true,
                "sig_header_name":"sig-bin",
                "tls_cert":"${escape ../build/swarm/btc-lsp/cert.pem as Text}",
                "tls_key":"${escape ../build/swarm/btc-lsp/key.pem as Text}"
              }
              ''
          , LSP_ELECTRS_ENV =
              ''
              {
                "host":"electrs",
                "port":"80"
              }
              ''
          , LSP_BITCOIND_ENV =
              ''
              {
                "host":"http://bitcoind:80",
                "username":"bitcoinrpc",
                "password":"developer"
              }
              ''
          }
        , networks.global = mempty
        }
      , docker-proxy =
        { hostname = "docker-proxy"
        , image = "heathmont/docker-proxy:v0.1.0-fdb6beb"
        , ports = [ "80:80/tcp", "443:443/tcp" ]
        , networks.global = mempty
        }
      }
    }
