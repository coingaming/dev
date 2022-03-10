let K = ./Kubernetes/Import.dhall

let name = "electrs"

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
                , env = Some
                  [ K.EnvVar::{
                    , name = "BITCOIND_USER"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "bitcoind_user"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "BITCOIND_PASSWORD"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "bitcoind_password"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "NETWORK"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "network"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "ELECTRUM_RPC_ADDR"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "electrum_rpc_addr"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "DAEMON_RPC_ADDR"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "daemon_rpc_addr"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "WAIT_DURATION_SECS"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "wait_duration_secs"
                        , name = Some name
                        }
                      }
                    }
                  ]
                , name
                , image = Some ../build/docker-image-electrs.txt as Text
                , ports = Some [ K.ContainerPort::{ containerPort = 8080 } ]
                , volumeMounts = Some
                  [ K.VolumeMount::{ mountPath = "/.electrs/db", name } ]
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
