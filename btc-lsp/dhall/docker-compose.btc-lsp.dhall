let P = ./Prelude/Import.dhall

let unJson
    : P.JSON.Type → Text
    = λ(x : P.JSON.Type) → Text/replace "\\u0024" "\$" (P.JSON.renderCompact x)

let escape
    : Text → Text
    = λ(x : Text) → Text/replace "\"" "" (unJson (P.JSON.string x))

in  { networks.global.external = True
    , version = "3"
    , volumes.postgres = [] : P.Map.Type Text Text
    , services.postgres
      =
      { image = "heathmont/postgres:11-alpine-a2e8bbe"
      , hostname = "postgres"
      , environment =
        { POSTGRES_MULTIPLE_DATABASES = "\"btc-lsp\""
        , POSTGRES_PASSWORD = "developer"
        , POSTGRES_USER = "btc-lsp"
        }
      , volumes = [ "postgres:/var/lib/postgresql/data" ]
      , networks.global = [] : P.Map.Type Text Text
      }
    , services.btc-lsp
      =
      { image = ../build/docker-image-btc-lsp.txt as Text
      , hostname = "btc-lsp"
      , ports = [ "8443:8443/tcp" ]
      , environment =
        { -- General
          LSP_LIBPQ_CONN_STR = "postgresql://btc-lsp:developer@postgres/btc-lsp"
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
              "lnd_tls_cert":"${escape ../build/lnd_tls.cert as Text}",
              "lnd_hex_macaroon":"0201036C6E6402CF01030A10634D5C8D3227E9F63529F82690C1898E1201301A160A0761646472657373120472656164120577726974651A130A04696E666F120472656164120577726974651A170A08696E766F69636573120472656164120577726974651A160A076D657373616765120472656164120577726974651A170A086F6666636861696E120472656164120577726974651A160A076F6E636861696E120472656164120577726974651A140A057065657273120472656164120577726974651A120A067369676E6572120867656E657261746500000620EB31C7413A5A44D14705852F8C0CA399104658C40AC866918C1D4B981DF2E71E",
              "lnd_host":"localhost",
              "lnd_port":11009,
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
              "sig_header_name":"signable-secp256k1-signature",
              "tls_cert":"${escape ../build/btc_lsp_tls_cert.pem as Text}",
              "tls_key":"${escape ../build/btc_lsp_tls_key.pem as Text}"
            }
            ''
        }
      , networks.global = [] : P.Map.Type Text Text
      }
    }
