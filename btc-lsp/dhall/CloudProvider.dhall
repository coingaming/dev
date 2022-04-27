let P = ./Prelude/Import.dhall

let ProviderType
    : Type
    = < Aws | DigitalOcean >

let mkServiceAnnotations
    : ProviderType → P.Map.Type Text Text
    = λ(cloudProvider : ProviderType) →
        merge
          { Aws =
            [ { mapKey = "service.beta.kubernetes.io/aws-load-balancer-type"
              , mapValue = "external"
              }
            , { mapKey =
                  "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type"
              , mapValue = "ip"
              }
            , { mapKey = "service.beta.kubernetes.io/aws-load-balancer-scheme"
              , mapValue = "internet-facing"
              }
            ]
          , DigitalOcean =
            [ { mapKey = "service.beta.kubernetes.io/do-loadbalancer-size-unit"
              , mapValue = "1"
              }
            , { mapKey =
                  "service.beta.kubernetes.io/do-loadbalancer-disable-lets-encrypt-dns-records"
              , mapValue = "true"
              }
            ]
          }
          cloudProvider

let mkIngressClassName
    : ProviderType → Text
    = λ(cloudProvider : ProviderType) →
        merge { Aws = "alb", DigitalOcean = "nginx" } cloudProvider

let mkIngressAnnotations
    : Text → ProviderType → Optional (P.Map.Type Text Text)
    = λ(certArn : Text) →
      λ(cloudProvider : ProviderType) →
        merge
          { Aws = Some
            [ { mapKey = "alb.ingress.kubernetes.io/scheme"
              , mapValue = "internet-facing"
              }
            , { mapKey = "alb.ingress.kubernetes.io/target-type"
              , mapValue = "ip"
              }
            , { mapKey = "alb.ingress.kubernetes.io/certificate-arn"
              , mapValue = certArn
              }
            , { mapKey = "alb.ingress.kubernetes.io/ssl-redirect"
              , mapValue = "443"
              }
            ]
          , DigitalOcean = None (P.Map.Type Text Text)
          }
          cloudProvider

in  { ProviderType
    , mkServiceAnnotations
    , mkIngressClassName
    , mkIngressAnnotations
    }
