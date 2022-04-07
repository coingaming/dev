let P = ../Prelude/Import.dhall

let K = ./Import.dhall

let ServiceType
    : Type
    = < ClusterIP | NodePort | LoadBalancer >

let unServiceType
    : ServiceType → Text
    = λ(x : ServiceType) →
        merge
          { ClusterIP = "ClusterIP"
          , NodePort = "NodePort"
          , LoadBalancer = "LoadBalancer"
          }
          x

let mkPorts
    : List Natural → List K.ServicePort.Type
    = λ(ports : List Natural) →
        P.List.map
          Natural
          K.ServicePort.Type
          ( λ(port : Natural) →
              K.ServicePort::{
              , name = Some (Natural/show port)
              , port
              , targetPort = Some (K.NatOrString.Nat port)
              }
          )
          ports

let CloudProvider
    : Type
    = < Aws | DigitalOcean >

let mkAnnotations
    : CloudProvider → Text → Optional (List { mapKey : Text, mapValue : Text })
    = λ(provider : CloudProvider) →
      λ(name : Text) →
        merge
          { Aws = None (List { mapKey : Text, mapValue : Text })
          , DigitalOcean = Some
            [ { mapKey = "kubernetes.digitalocean.com/load-balancer-id"
              , mapValue = "${name}-lb"
              }
            , { mapKey = "service.beta.kubernetes.io/do-loadbalancer-size-unit"
              , mapValue = "1"
              }
            , { mapKey =
                  "service.beta.kubernetes.io/do-loadbalancer-disable-lets-encrypt-dns-records"
              , mapValue = "true"
              }
            ]
          }
          provider

let mkService
    : Text →
      Optional (List { mapKey : Text, mapValue : Text }) →
      ServiceType →
      List K.ServicePort.Type →
        K.Service.Type
    = λ(name : Text) →
      λ(annotations : Optional (List { mapKey : Text, mapValue : Text })) →
      λ(type : ServiceType) →
      λ(ports : List K.ServicePort.Type) →
        let name = name

        in  K.Service::{
            , metadata = K.ObjectMeta::{ name = Some name, annotations }
            , spec = Some K.ServiceSpec::{
              , type = Some (unServiceType type)
              , selector = Some [ { mapKey = "name", mapValue = name } ]
              , ports = Some ports
              }
            }

in  { ServiceType, CloudProvider, mkAnnotations, mkPorts, mkService }
