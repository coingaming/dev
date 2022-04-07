let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Lsp = ../Service/Lsp.dhall

let owner = G.unOwner G.Owner.Integration

let image = ../../build/docker-image-integration.txt as Text

let env =
      { integrationGrpcClientEnv = "LSP_GRPC_CLIENT_ENV"
      , integrationLndEnv2 = "LND_LSP_ENV"
      }

let ports
    : List Natural
    = G.unPorts [ Lsp.grpcPort ]

let mkServiceType
    : G.BitcoinNetwork → Service.ServiceType
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.ServiceType.ClusterIP
          , TestNet = Service.ServiceType.ClusterIP
          , RegTest = Service.ServiceType.NodePort
          }
          net

let mkServiceAnnotations
    : G.BitcoinNetwork → Optional (List { mapKey : Text, mapValue : Text })
    = λ(net : G.BitcoinNetwork) → None (List { mapKey : Text, mapValue : Text })

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
        Service.mkService
          owner
          (mkServiceAnnotations net)
          (mkServiceType net)
          (Service.mkPorts ports)

let configMapEnv
    : List Text
    = [ env.integrationGrpcClientEnv
      , Lsp.env.lspLndP2pHost
      , Lsp.env.lspLndP2pPort
      , Lsp.env.lspLogEnv
      , Lsp.env.lspLogFormat
      , Lsp.env.lspLogSeverity
      , Lsp.env.lspLogVerbosity
      , Lsp.env.lspMinChanCapMsat
      ]

let secretEnv
    : List Text
    = [ env.integrationLndEnv2
      , Lsp.env.lspGrpcServerEnv
      , Lsp.env.lspLndEnv
      , Lsp.env.lspLibpqConnStr
      , Lsp.env.lspBitcoindEnv
      ]

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

in  { env, configMapEnv, secretEnv, mkService, mkDeployment }
