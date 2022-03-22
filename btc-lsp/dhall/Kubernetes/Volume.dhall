let K = ./Import.dhall

let G = ../Global.dhall

let Suffix
    : Type
    = < Kilobyte | Megabyte | Gigabyte | Terabyte | Petabyte | Exabyte >

let Size = { Type = { capacity : Natural, suffix : Suffix }, default = {=} }

let unSuffix
    : Suffix → Text
    = λ(x : Suffix) →
        merge
          { Kilobyte = "Ki"
          , Megabyte = "Mi"
          , Gigabyte = "Gi"
          , Terabyte = "Ti"
          , Petabyte = "Pi"
          , Exabyte = "Ei"
          }
          x

let unSize
    : Size.Type → Text
    = λ(size : Size.Type) →
        Natural/show size.capacity ++ "${unSuffix size.suffix}"

let mkPersistentVolumeClaim
    : Text → Size.Type → K.PersistentVolumeClaim.Type
    = λ(name : Text) →
      λ(size : Size.Type) →
        let name = name

        in  K.PersistentVolumeClaim::{
            , metadata = K.ObjectMeta::{ name = Some name }
            , spec = Some K.PersistentVolumeClaimSpec::{
              , accessModes = Some [ "ReadWriteOnce" ]
              , resources = Some K.ResourceRequirements::{
                , requests = Some
                  [ { mapKey = "storage", mapValue = unSize size } ]
                }
              }
            }

in  { Suffix, Size, mkPersistentVolumeClaim }
