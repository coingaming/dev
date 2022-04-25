let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let K = ./Import.dhall

let mkAnnotations
    : Text → G.CloudProvider → Optional (P.Map.Type Text Text)
    = λ(name : Text) →
      λ(cloudProvider : G.CloudProvider) →
        merge
          { Aws = Some
            [ { mapKey = "alb.ingress.kubernetes.io/scheme"
              , mapValue = "internet-facing"
              }
            , { mapKey = "alb.ingress.kubernetes.io/target-type"
              , mapValue = "ip"
              }
            ]
          , DigitalOcean = None (P.Map.Type Text Text)
          }
          cloudProvider

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
      Optional (P.Map.Type Text Text) →
      Text →
      Natural →
      Optional Text →
      Optional (List K.IngressTLS.Type) →
        K.Ingress.Type
    = λ(name : Text) →
      λ(annotations : Optional (P.Map.Type Text Text)) →
      λ(host : Text) →
      λ(port : Natural) →
      λ(ingressClassName : Optional Text) →
      λ(tls : Optional (List K.IngressTLS.Type)) →
        K.Ingress::{
        , metadata = K.ObjectMeta::{ name = Some name, annotations }
        , spec = Some K.IngressSpec::{
          , ingressClassName
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

in  { mkAnnotations, mkIngressClassName, mkTls, mkIngress }
