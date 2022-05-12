let P = ../Prelude/Import.dhall

let K = ./Import.dhall

let mkTls
    : Text → Text → K.IngressTLS.Type
    = λ(host : Text) →
      λ(secret : Text) →
        K.IngressTLS::{ hosts = Some [ host ], secretName = Some secret }

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

in  { mkTls, mkIngress }
