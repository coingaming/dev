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
                  [ K.EnvVar::{ name = "CONFIG_FROM_ENV", value = Some "true" }
                  , K.EnvVar::{ name = "DISABLEWALLET", value = Some "0" }
                  , K.EnvVar::{ name = "PRUNE", value = Some "0" }
                  , K.EnvVar::{ name = "REGTEST", value = Some "1" }
                  , K.EnvVar::{ name = "RPCALLOWIP", value = Some "0.0.0.0/0" }
                  , K.EnvVar::{ name = "RPCBIND", value = Some ":18332" }
                  , K.EnvVar::{ name = "RPCPASSWORD", value = Some "developer" }
                  , K.EnvVar::{ name = "RPCPORT", value = Some "18332" }
                  , K.EnvVar::{ name = "RPCUSER", value = Some "bitcoinrpc" }
                  , K.EnvVar::{ name = "SERVER", value = Some "1" }
                  , K.EnvVar::{ name = "TESTNET", value = Some "0" }
                  , K.EnvVar::{ name = "TXINDEX", value = Some "1" }
                  , K.EnvVar::{
                    , name = "ZMQPUBRAWBLOCK"
                    , value = Some "tcp://0.0.0.0:39703"
                    }
                  , K.EnvVar::{
                    , name = "ZMQPUBRAWTX"
                    , value = Some "tcp://0.0.0.0:39704"
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
