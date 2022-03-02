let P = ./Prelude/Import.dhall

let K = ./Kubernetes/Import.dhall

let name = "rtl"

let ingress =
    K.Ingress::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.IngressSpec::{
        rules = Some [K.IngressRule::{
          host = Some name
          , http = Some K.HTTPIngressRuleValue::{
            paths = [K.HTTPIngressPath::{
              backend = K.IngressBackend::{
                service = Some K.IngressServiceBackend::{
                  name = name
                , port = Some K.ServiceBackendPort::{
                  number = Some 80
                }
                }
              }
              , pathType = "Prefix"
            }]
          }
        }]
      }
    }

in  ingress
