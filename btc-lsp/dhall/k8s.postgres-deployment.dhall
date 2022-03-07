let K = ./Kubernetes/Import.dhall

let name = "postgres"

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
                    , name = "POSTGRES_MULTIPLE_DATABASES"
                    , valueFrom = Some K.EnvVarSource::{
                      , configMapKeyRef = Some K.ConfigMapKeySelector::{
                        , key = "postgres_multiple_databases"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "POSTGRES_USER"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "postgres_user"
                        , name = Some name
                        }
                      }
                    }
                  , K.EnvVar::{
                    , name = "POSTGRES_PASSWORD"
                    , valueFrom = Some K.EnvVarSource::{
                      , secretKeyRef = Some K.SecretKeySelector::{
                        , key = "postgres_password"
                        , name = Some name
                        }
                      }
                    }
                  ]
                , name
                , image = Some "heathmont/postgres:11-alpine-a2e8bbe"
                , ports = Some [ K.ContainerPort::{ containerPort = 5432 } ]
                , volumeMounts = Some
                  [ K.VolumeMount::{
                    , mountPath = "/var/lib/postgresql/data"
                    , name
                    }
                  ]
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
