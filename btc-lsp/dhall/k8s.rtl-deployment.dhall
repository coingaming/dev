let K = ./Kubernetes/Import.dhall

let name = "rtl"

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
                , image = Some "heathmont/rtl:9c8d7d6"
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
                    , name = "RTL_CONFIG_JSON"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "rtl_config_json"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "RTL_CONFIG_NODES_JSON"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "rtl_config_nodes_json"
                        , name = Some name
                        }
                      }
                    }
                  ]
                , ports = Some [ K.ContainerPort::{ containerPort = 80 } ]
                }
              ]
            , hostname = Some name
            , restartPolicy = Some "Always"
            }
          }
        }
      }

in  deployment
