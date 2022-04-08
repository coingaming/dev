let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Ingress = ../Kubernetes/Ingress.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Lnd = ./Lnd.dhall

let owner = G.unOwner G.Owner.Rtl

let image = "heathmont/rtl:9c8d7d6"

let domain = ../../build/secrets/rtl/domain.txt as Text ? G.todo

let tlsSecretName = "${owner}-tls"

let securePass = ../../build/secrets/rtl/multipass.txt as Text ? G.todo

let tcpPort
    : G.Port
    = { unPort = 3000 }

let env =
      { configFromEnv = "CONFIG_FROM_ENV"
      , rtlConfigJson = "RTL_CONFIG_JSON"
      , rtlConfigNodesJson = "RTL_CONFIG_NODES_JSON"
      }

let ports
    : List Natural
    = G.unPorts [ tcpPort ]

let mkMultiPass
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = securePass
          , TestNet = securePass
          , RegTest = G.defaultPass
          }
          net

let mkDomain
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge { MainNet = domain, TestNet = domain, RegTest = owner } net

let mkRtlConfigNodesJson
    : List G.Owner → P.JSON.Type
    = λ(lndOwners : List G.Owner) →
        let nodeConfigs =
              P.List.map
                { index : Natural, value : G.Owner }
                P.JSON.Type
                ( λ(owner : { index : Natural, value : G.Owner }) →
                    P.JSON.object
                      ( toMap
                          { hexMacaroon =
                              P.JSON.string (Lnd.mkHexMacaroon owner.value)
                          , index = P.JSON.natural (owner.index + 1)
                          , lnServerUrl =
                              P.JSON.string
                                "${G.unNetworkScheme
                                     G.NetworkScheme.Https}://${G.unOwner
                                                                  owner.value}:${G.unPort
                                                                                   Lnd.restPort}"
                          }
                      )
                )
                (P.List.indexed G.Owner lndOwners)

        in  P.JSON.array nodeConfigs

let mkRtlConfigJson
    : G.BitcoinNetwork → P.JSON.Type
    = λ(net : G.BitcoinNetwork) →
        P.JSON.object
          ( toMap
              { multiPass = P.JSON.string (mkMultiPass net)
              , port = P.JSON.natural tcpPort.unPort
              , defaultNodeIndex = P.JSON.natural 1
              , SSO =
                  P.JSON.object
                    ( toMap
                        { rtlSSO = P.JSON.natural 0
                        , rtlCookiePath = P.JSON.string ""
                        , logoutRedirectLink = P.JSON.string ""
                        }
                    )
              , nodes = P.JSON.array ([] : List P.JSON.Type)
              }
          )

let mkEnv
    : G.BitcoinNetwork → List G.Owner → P.Map.Type Text Text
    = λ(net : G.BitcoinNetwork) →
      λ(lndOwners : List G.Owner) →
        [ { mapKey = env.configFromEnv, mapValue = "true" }
        , { mapKey = env.rtlConfigNodesJson
          , mapValue = "'${P.JSON.render (mkRtlConfigNodesJson lndOwners)}'"
          }
        , { mapKey = env.rtlConfigJson
          , mapValue = "'${P.JSON.render (mkRtlConfigJson net)}'"
          }
        ]

let mkServiceType
    : G.BitcoinNetwork → Service.ServiceType
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.ServiceType.ClusterIP
          , TestNet = Service.ServiceType.ClusterIP
          , RegTest = Service.ServiceType.ClusterIP
          }
          net

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
        Service.mkService
          owner
          (None (List { mapKey : Text, mapValue : Text }))
          (mkServiceType net)
          (Service.mkPorts ports)

let mkTls
    : G.BitcoinNetwork → Optional K.IngressTLS.Type
    = λ(net : G.BitcoinNetwork) →
        let tls = Some (Ingress.mkTls (mkDomain net) tlsSecretName)

        in  merge
              { MainNet = tls, TestNet = tls, RegTest = None K.IngressTLS.Type }
              net

let mkIngress
    : G.BitcoinNetwork → K.Ingress.Type
    = λ(net : G.BitcoinNetwork) →
        let tls
            : Optional (List K.IngressTLS.Type)
            = P.Optional.map
                K.IngressTLS.Type
                (List K.IngressTLS.Type)
                (λ(tls : K.IngressTLS.Type) → [ tls ])
                (mkTls net)

        in  Ingress.mkIngress owner (mkDomain net) tcpPort.unPort tls

let configMapEnv
    : List Text
    = [ env.configFromEnv ]

let secretEnv
    : List Text
    = [ env.rtlConfigJson, env.rtlConfigNodesJson ]

let mkContainerEnv =
        Deployment.mkEnv Deployment.EnvVarType.ConfigMap owner configMapEnv
      # Deployment.mkEnv Deployment.EnvVarType.Secret owner secretEnv

let mkContainer
    : Text → G.BitcoinNetwork → K.Container.Type
    = λ(name : Text) →
      λ(net : G.BitcoinNetwork) →
        K.Container::{
        , name
        , image = Some image
        , env = Some mkContainerEnv
        , ports = Some (Deployment.mkContainerPorts ports)
        }

let mkDeployment
    : G.BitcoinNetwork → K.Deployment.Type
    = λ(net : G.BitcoinNetwork) →
        Deployment.mkDeployment
          owner
          (None K.DeploymentStrategy.Type)
          [ mkContainer owner net ]
          (None (List K.Volume.Type))

in  { tlsSecretName
    , mkEnv
    , configMapEnv
    , secretEnv
    , mkService
    , mkDeployment
    , mkIngress
    }
