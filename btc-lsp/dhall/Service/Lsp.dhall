let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Lsp

let image = "olegkivi/btc-lsp:8a274h12x8q8gc4p63m7yzcy8g307vip"

let aes256InitVector = "dRgUkXp2s5v8y/B?"

let aes256SecretKey = "y?B&E)H@MbQeThWmZq4t7w!z%C*F-JaN"

let logEnv = "test"

let logFormat = "Bracket"

let logVerbosity = "V3"

let logSeverity = "DebugS"

let tlsCert = ../../build/lsp/tls.cert as Text ? G.todo

let tlsKey = ../../build/lsp/tls.key as Text ? G.todo

let grpcPort
    : G.Port
    = { unPort = 8443 }

let env =
      { lspAes256InitVector = "LSP_AES256_INIT_VECTOR"
      , lspAes256SecretKey = "LSP_AES256_SECRET_KEY"
      , lspEndpointPort = "LSP_ENDPOINT_PORT"
      , lspLogEnv = "LSP_LOG_ENV"
      , lspLogFormat = "LSP_LOG_FORMAT"
      , lspLogVerbosity = "LSP_LOG_VERBOSITY"
      , lspLogSeverity = "LSP_LOG_SEVERITY"
      , lspLndP2pHost = "LSP_LND_P2P_HOST"
      , lspLndP2pPort = "LSP_LND_P2P_PORT"
      , lspElectrsEnv = "LSP_ELECTRS_ENV"
      , lspLibpqConnStr = "LSP_LIBPQ_CONN_STR"
      , lspLndEnv = "LSP_LND_ENV"
      , lspGrpcServerEnv = "LSP_GRPC_SERVER_ENV"
      , lspBitcoindEnv = "LSP_BITCOIND_ENV"
      }

let ports
    : List Natural
    = G.unPorts [ grpcPort ]

let mkServiceType
    : G.BitcoinNetwork → Service.ServiceType
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.ServiceType.LoadBalancer
          , TestNet = Service.ServiceType.LoadBalancer
          , RegTest = Service.ServiceType.NodePort
          }
          net

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
        Service.mkService owner (mkServiceType net) (Service.mkPorts ports)

let configMapEnv
    : List Text
    = [ env.lspEndpointPort
      , env.lspLogEnv
      , env.lspLogFormat
      , env.lspLogVerbosity
      , env.lspLogSeverity
      , env.lspLndP2pHost
      , env.lspLndP2pPort
      , env.lspElectrsEnv
      ]

let secretEnv
    : List Text
    = [ env.lspLibpqConnStr
      , env.lspLndEnv
      , env.lspGrpcServerEnv
      , env.lspBitcoindEnv
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

in  { aes256InitVector
    , aes256SecretKey
    , logEnv
    , logFormat
    , logVerbosity
    , logSeverity
    , tlsCert
    , tlsKey
    , env
    , grpcPort
    , mkService
    , mkDeployment
    }
