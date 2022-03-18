let K = ./Kubernetes/Import.dhall

let name = "postgres"

let service =
      K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , selector = Some [ { mapKey = "name", mapValue = name } ]
        , ports = Some
          [ K.ServicePort::{
            , name = Some "5432"
            , port = 5432
            , targetPort = Some (K.NatOrString.Nat 5432)
            }
          ]
        }
      }

in  service
