let P = ./Prelude/Import.dhall

let K = ./Kubernetes/Import.dhall

let name = "lnd-lsp"

let persistentVolumeClaim =
    K.PersistentVolumeClaim::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.PersistentVolumeClaimSpec::{
        accessModes = Some ["ReadWriteOnce"]
        , resources = Some K.ResourceRequirements::{
          requests = Some [
            { mapKey = "storage", mapValue = "100Mi" }
          ]
        }
      }
    }

in  persistentVolumeClaim
