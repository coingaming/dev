let K = ./Kubernetes/Import.dhall

let name = "bitcoind"

let service =
      K.Service::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.ServiceSpec::{
        , type = Some "NodePort"
        , selector = Some [ { mapKey = "name", mapValue = name } ]
        , ports = Some
          [ K.ServicePort::{
            , name = Some "39703"
            , port = 39703
            , targetPort = Some (K.NatOrString.Nat 39703)
            , nodePort = Some 30703
            }
          , K.ServicePort::{
            , name = Some "39704"
            , port = 39704
            , targetPort = Some (K.NatOrString.Nat 39704)
            , nodePort = Some 30704
            }
          , K.ServicePort::{
            , name = Some "18332"
            , port = 18332
            , targetPort = Some (K.NatOrString.Nat 18332)
            , nodePort = Some 30332
            }
          ]
        }
      }

in  service
