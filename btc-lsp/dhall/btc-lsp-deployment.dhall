let P = ./Prelude/Import.dhall

let K = ./Kubernetes/Import.dhall

let name = "btc-lsp"

let todo
    : Text
    = "TODO"

let unJson
    : P.JSON.Type → Text
    = λ(x : P.JSON.Type) → Text/replace "\\u0024" "\$" (P.JSON.renderCompact x)

let escape
    : Text → Text
    = λ(x : Text) → Text/replace "\"" "" (unJson (P.JSON.string x))

let deployment =
    K.Deployment::{
    , metadata = K.ObjectMeta::{ name = Some name }
    , spec = Some K.DeploymentSpec::{
      , selector = K.LabelSelector::{
        , matchLabels = Some (toMap { name = name })
        }
      , replicas = Some 1
      , template = K.PodTemplateSpec::{
        , metadata = Some K.ObjectMeta::{ labels = Some [{mapKey = "name", mapValue = name}] }
        , spec = Some K.PodSpec::{
          , containers =
            [ K.Container::{
              , env = Some
                [ 
                  -- General
                    K.EnvVar::{name = "LSP_LIBPQ_CONN_STR", value = Some "postgresql://btc-lsp:developer@postgres/btc-lsp"}
                  , K.EnvVar::{name = "LSP_ENDPOINT_PORT", value = Some "443"}
                  -- Logging
                  , K.EnvVar::{name = "LSP_LOG_ENV", value = Some "test"} 
                  , K.EnvVar::{name = "LSP_LOG_FORMAT", value = Some "Bracket"}
                  , K.EnvVar::{name = "LSP_LOG_VERBOSITY", value = Some "V3"}
                  , K.EnvVar::{name = "LSP_LOG_SEVERITY", value = Some "DebugS"}
                  -- Encryption
                  , K.EnvVar::{name = "LSP_AES256_INIT_VECTOR", value = Some "dRgUkXp2s5v8y/B?"} 
                  , K.EnvVar::{name = "LSP_AES256_SECRET_KEY", value = Some "y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN"} 
                  -- Rpc
                  , K.EnvVar::{name = "LSP_LND_ENV", value = Some 
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
                  }
                  , K.EnvVar::{name = "LSP_GRPC_SERVER_ENV", value = Some 
                  ''
                  {
                    "port":443,
                    "sig_verify":true,
                    "sig_header_name":"sig-bin",
                    "tls_cert":"${escape ../build/swarm/btc-lsp/cert.pem as Text}",
                    "tls_key":"${escape ../build/swarm/btc-lsp/key.pem as Text}"
                  }
                  ''
                  }
                  , K.EnvVar::{name = "LSP_BITCOIND_ENV", value = Some 
                  ''
                  {
                    "host":"http://bitcoind:80",
                    "username":"bitcoinrpc",
                    "password":"developer"
                  }
                  ''
                  }
                  , K.EnvVar::{name = "LSP_ELECTRS_ENV", value = Some 
                  ''
                  {
                    "host":"electrs",
                    "port":"80"
                  }
                  ''
                  }
                ]
              , name = name
              , image = Some ../build/docker-image-btc-lsp.txt as Text
              , ports = Some
                [ K.ContainerPort::{ containerPort = 8443 } ]
              }
            ]
          , hostname = Some name
          , restartPolicy = Some "Always"
        }
      }
    }
  }

in  deployment
