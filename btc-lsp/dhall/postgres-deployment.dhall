let P = ./Prelude/Import.dhall

let K = ./Kubernetes/Import.dhall

let name = "postgres"

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
                  K.EnvVar::{name = "POSTGRES_MULTIPLE_DATABASES", value = Some "\"btc-lsp\""} 
                  , K.EnvVar::{name = "POSTGRES_PASSWORD", value = Some "developer"} 
                  , K.EnvVar::{name = "POSTGRES_USER", value = Some "btc-lsp"} 
                ]
              , name = name
              , image = Some "heathmont/postgres:11-alpine-a2e8bbe"
              , ports = Some
                [ K.ContainerPort::{ containerPort = 5432 } ]
              , volumeMounts = Some [ K.VolumeMount::{ mountPath = "/var/lib/postgresql/data", name = name } ]
              }
            ]
          , hostname = Some name
          , restartPolicy = Some "Always"
          , volumes = Some [K.Volume::{
            name = name, 
            persistentVolumeClaim = Some K.PersistentVolumeClaimVolumeSource::{claimName = name}}]
          }

        }
      }
    }

in  deployment
