let K = ./Kubernetes/Import.dhall

let name = "btc-lsp"

let service =
      K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , selector = Some [ { mapKey = "name", mapValue = name } ]
        , ports = Some
          [ K.ServicePort::{
            , name = Some "8443"
            , port = 8443
            , targetPort = Some (K.IntOrString.Int (Natural/toInteger 8443))
            }
          ]
        }
      }

in  service
