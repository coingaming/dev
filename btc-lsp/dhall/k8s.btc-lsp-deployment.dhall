let K = ./Kubernetes/Import.dhall

let name = "btc-lsp"

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
                    , name = "LSP_LIBPQ_CONN_STR"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "lsp_libpq_conn_str"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_LOG_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lsp_log_env"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_LOG_FORMAT"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lsp_log_format"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_LOG_VERBOSITY"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lsp_log_verbosity"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_LOG_SEVERITY"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lsp_log_severity"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_LND_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "lsp_lnd_env"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_GRPC_SERVER_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "lsp_grpc_server_env"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_BITCOIND_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "lsp_bitcoind_env"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "LSP_ELECTRS_ENV"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "lsp_electrs_env"
                        , name = Some name
                        }
                      }
                    }
                  ]
                , name
                , image = Some ../build/docker-image-btc-lsp.txt as Text
                , ports = Some [ K.ContainerPort::{ containerPort = 8443 } ]
                }
              ]
            , hostname = Some name
            , restartPolicy = Some "Always"
            }
          }
        }
      }

in  deployment
