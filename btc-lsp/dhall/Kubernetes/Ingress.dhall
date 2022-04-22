let G = ../Global.dhall

let K = ./Import.dhall

let mkTls
    : Text → Text → K.IngressTLS.Type
    = λ(host : Text) →
      λ(secret : Text) →
        K.IngressTLS::{ hosts = Some [ host ], secretName = Some secret }

let mkIngressClassName
    : G.CloudProvider → Text
    = λ(cloudProvider : G.CloudProvider) →
        merge { Aws = "alb", DigitalOcean = "nginx" } cloudProvider

let mkIngress
    : Text →
      Text →
      Natural →
      G.CloudProvider →
      Optional (List K.IngressTLS.Type) →
        K.Ingress.Type
    = λ(name : Text) →
      λ(host : Text) →
      λ(port : Natural) →
      λ(cloudProvider : G.CloudProvider) →
      λ(tls : Optional (List K.IngressTLS.Type)) →
        K.Ingress::{
        , metadata = K.ObjectMeta::{ name = Some name }
        , spec = Some K.IngressSpec::{
          , ingressClassName = Some (mkIngressClassName cloudProvider)
          , tls
          , rules = Some
            [ K.IngressRule::{
              , host = Some host
              , http = Some K.HTTPIngressRuleValue::{
                , paths =
                  [ K.HTTPIngressPath::{
                    , backend = K.IngressBackend::{
                      , service = Some K.IngressServiceBackend::{
                        , name
                        , port = Some K.ServiceBackendPort::{
                          , number = Some port
                          }
                        }
                      }
                    , path = Some "/"
                    , pathType = "Prefix"
                    }
                  ]
                }
              }
            ]
          }
        }

in  { mkIngress, mkTls }
