let P = ./Prelude/Import.dhall

let K = ./Kubernetes/Import.dhall

let name = "btc-lsp"

let service =
    K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , type = Some "NodePort"
        , selector = Some [{mapKey = "name", mapValue = name}]
        , ports = Some [
          K.ServicePort::{
              name = Some "9735"
              , port = 9735
              , targetPort = Some (K.IntOrString.Int (Natural/toInteger 9735))
              , nodePort = Some 39735
            }
          }
        ,  K.ServicePort::{
              name = Some "10009"
              , port = 10009
              , targetPort = Some (K.IntOrString.Int (Natural/toInteger 10009))
            }
          }
        , K.ServicePort::{
              name = Some "8080"
              , port = 8080
              , targetPort = Some (K.IntOrString.Int (Natural/toInteger 8080))
            }
          }
    }

in  service
