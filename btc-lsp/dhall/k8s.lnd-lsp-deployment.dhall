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
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoin_defaultchanconfs"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_NETWORK"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoin_network"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCHOST"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoin_rpchost"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCPASS"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "bitcoin_rpcpass"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_RPCUSER"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "bitcoin_rpcuser"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_ZMQPUBRAWBLOCK"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoin_zmqpubrawblock"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIN_ZMQPUBRAWTX"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoin_zmqpubrawtx"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LND_GRPC_PORT"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lnd_grpc_port"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LND_P2P_PORT"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lnd_p2p_port"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LND_REST_PORT"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lnd_rest_port"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "TLS_EXTRADOMAIN"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "tls_extradomain"
                        , name = Some name
                        }
                      }
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
