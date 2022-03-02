let K = ./Kubernetes/Import.dhall

let name = "lnd-lsp"

let deployment =
      K.Deployment::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.DeploymentSpec::{
        , selector = K.LabelSelector::{ matchLabels = Some (toMap { name }) }
        , replicas = Some 1
        , template = K.PodTemplateSpec::{
          , metadata = Some K.ObjectMeta::{
            , labels = Some [ { mapKey = "name", mapValue = name } ]
            }
          , spec = Some K.PodSpec::{
            , containers =
              [ K.Container::{
                , name
                , image = Some "lightninglabs/lnd:v0.13.1-beta.rc2"
                , args = Some
                  [ "-c"
                  , "lnd --bitcoin.active --bitcoin.\$\$BITCOIN_NETWORK --bitcoin.node=bitcoind --bitcoin.defaultchanconfs=\$\$BITCOIN_DEFAULTCHANCONFS --bitcoind.rpchost=\$\$BITCOIN_RPCHOST --bitcoind.rpcuser=\$\$BITCOIN_RPCUSER --bitcoind.rpcpass=\$\$BITCOIN_RPCPASS --bitcoind.zmqpubrawblock=\$\$BITCOIN_ZMQPUBRAWBLOCK --bitcoind.zmqpubrawtx=\$\$BITCOIN_ZMQPUBRAWTX --tlsextradomain=\$\$TLS_EXTRADOMAIN --restlisten=0.0.0.0:\$\$LND_REST_PORT --rpclisten=0.0.0.0:\$\$LND_GRPC_PORT --listen=0.0.0.0:\$\$LND_P2P_PORT --maxpendingchannels=100"
                  ]
                , command = Some [ "sh" ]
                , env = Some
                  [ K.EnvVar::{
                    , name = "BITCOIN_DEFAULTCHANCONFS"
                    , value = Some "1"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_NETWORK"
                    , value = Some "regtest"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCHOST"
                    , value = Some "bitcoind:18332"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCPASS"
                    , value = Some "developer"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCUSER"
                    , value = Some "bitcoinrpc"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_ZMQPUBRAWBLOCK"
                    , value = Some "tcp://bitcoind:39703"
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_ZMQPUBRAWTX"
                    , value = Some "tcp://bitcoind:39704"
                    }
                  , K.EnvVar::{ name = "LND_GRPC_PORT", value = Some "10009" }
                  , K.EnvVar::{ name = "LND_P2P_PORT", value = Some "9735" }
                  , K.EnvVar::{ name = "LND_REST_PORT", value = Some "8080" }
                  , K.EnvVar::{
                    , name = "TLS_EXTRADOMAIN"
                    , value = Some "lnd-lsp"
                    }
                  ]
                , ports = Some
                  [ K.ContainerPort::{ containerPort = 8080 }
                  , K.ContainerPort::{ containerPort = 9735 }
                  , K.ContainerPort::{ containerPort = 10009 }
                  ]
                , volumeMounts = Some
                  [ K.VolumeMount::{ mountPath = "/root/.lnd", name } ]
                }
              ]
            , hostname = Some name
            , restartPolicy = Some "Always"
            , volumes = Some
              [ K.Volume::{
                , name
                , persistentVolumeClaim = Some K.PersistentVolumeClaimVolumeSource::{
                  , claimName = name
                  }
                }
              ]
            }
          }
        }
      }

in  deployment
