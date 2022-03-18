let K = ./Kubernetes/Import.dhall

let name = "rtl"

let service =
      K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , selector = Some [ { mapKey = "name", mapValue = name } ]
        , ports = Some
          [ K.ServicePort::{
            , name = Some "80"
            , port = 80
            , targetPort = Some (K.NatOrString.Nat 80)
            }
          ]
        }
      }

in  service
