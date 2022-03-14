let K = ./Kubernetes/Import.dhall

let name = "electrs"

let service =
      K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , selector = Some [ { mapKey = "name", mapValue = name } ]
        , ports = Some
          [ K.ServicePort::{
            , name = Some "8080"
            , port = 8080
            , targetPort = Some (K.IntOrString.Int (Natural/toInteger 8080))
            }
          ]
        }
      }

in  service
