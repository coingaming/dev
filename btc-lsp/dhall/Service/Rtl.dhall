let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Ingress = ../Kubernetes/Ingress.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Rtl

let image = "heathmont/rtl:9c8d7d6"

let domain = ../../build/rtl/domain.txt as Text ? G.todo

let tlsSecretName = "${owner}-tls"

let securePass = ../../build/rtl/multipass.txt as Text ? G.todo

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

let mkRtlConfigJson
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        ''
        {
          "SSO":{
            "logoutRedirectLink": "",
            "rtlCookiePath": "",
            "rtlSSO": 0
          },
          "defaultNodeIndex": 1,
          "multiPass": "${mkMultiPass net}",
          "nodes": [],
          "port": "${G.unPort tcpPort}"
        }
        ''

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
        let tls = Some (Ingress.mkTls domain tlsSecretName)

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

        in  Ingress.mkIngress owner domain tcpPort.unPort tls

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
    , tcpPort
    , env
    , mkRtlConfigJson
    , mkService
    , mkDeployment
    , mkIngress
    }
