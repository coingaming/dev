let K = ./Kubernetes/Import.dhall

let name = "bitcoind"

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
                , image = Some "heathmont/bitcoind:v1.0.9"
                , env = Some
                  [ K.EnvVar::{
                    , name = "CONFIG_FROM_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "config_from_env"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "DISABLEWALLET"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "disablewallet"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "PRUNE"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "prune"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "REGTEST"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "regtest"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RPCALLOWIP"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "rpcallowip"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RPCBIND"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "rpcbind"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RPCUSER"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "rpcuser"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RPCPASSWORD"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "rpcpassword"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RPCPORT"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "rpcport"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "SERVER"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "server"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "TESTNET"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "testnet"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "TXINDEX"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "txindex"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "ZMQPUBRAWBLOCK"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "zmqpubrawblock"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "ZMQPUBRAWTX"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "zmqpubrawtx"
                        , name = Some name
                        }
                      }
                    }
                  ]
                , ports = Some
                  [ K.ContainerPort::{ containerPort = 18332 }
                  , K.ContainerPort::{ containerPort = 39703 }
                  , K.ContainerPort::{ containerPort = 39704 }
                  ]
                , volumeMounts = Some
                  [ K.VolumeMount::{ mountPath = "/bitcoin/.bitcoin", name } ]
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
