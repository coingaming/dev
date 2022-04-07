let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Bitcoind = ./Bitcoind.dhall

let Lnd = ./Lnd.dhall

let owner = G.unOwner G.Owner.Integration

let image = ../../build/docker-image-integration.txt as Text

let tlsCert = ../../build/lsp/inlined-tls.cert as Text ? G.todo

let tlsKey = ../../build/lsp/inlined-tls.key as Text ? G.todo

let grpcPort
    : G.Port
    = { unPort = 8443 }

let env =
      { integrationGrpcClientEnv = "LSP_GRPC_CLIENT_ENV"
      , integrationBitcoindEnv = "LSP_BITCOIND_ENV"
      , integrationGrpcServerEnv = "LSP_GRPC_SERVER_ENV"
      , integrationLndEnv = "LSP_LND_ENV"
      , integrationLndEnv2 = "LND_LSP_ENV"
      , integrationElectrsEnv = "LSP_ELECTRS_ENV"
      , integrationLibpqConnStr = "LSP_LIBPQ_CONN_STR"
      , integrationLndP2pHost = "LSP_LND_P2P_HOST"
      , integrationLndP2pPort = "LSP_LND_P2P_PORT"
      , integrationLogEnv = "LSP_LOG_ENV"
      , integrationLogFormat = "LSP_LOG_FORMAT"
      , integrationLogSeverity = "LSP_LOG_SEVERITY"
      , integrationLogVerbosity = "LSP_LOG_VERBOSITY"
      , integrationMinChanCapMsat = "LSP_MIN_CHAN_CAP_MSAT"
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

let mkIntegrationLndEnv
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        ''
        {
          "lnd_wallet_password":"${Lnd.mkWalletPass net}",
          "lnd_tls_cert":"${Lnd.tlsCert}",
          "lnd_hex_macaroon":"${Lnd.hexMacaroon}",
          "lnd_host":"${G.unOwner G.Owner.Lnd}",
          "lnd_port":${G.unPort Lnd.grpcPort}
        }
        ''

let mkServiceAnnotations
    : G.BitcoinNetwork → Optional (List { mapKey : Text, mapValue : Text })
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.mkAnnotations Service.CloudProvider.Aws owner
          , TestNet =
              Service.mkAnnotations Service.CloudProvider.DigitalOcean owner
          , RegTest = None (List { mapKey : Text, mapValue : Text })
          }
          net

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
        Service.mkService
          owner
          (mkServiceAnnotations net)
          (mkServiceType net)
          (Service.mkPorts ports)

let mkIntegrationBitcoindEnv
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        ''
        {
          "host":"${G.unNetworkScheme
                      G.NetworkScheme.Http}://${G.unOwner
                                                  G.Owner.Bitcoind}:${G.unPort
                                                                        ( Bitcoind.mkRpcPort
                                                                            net
                                                                        )}",
          "username":"${Bitcoind.mkRpcUser net}",
          "password":"${Bitcoind.mkRpcPass net}"
        }
        ''

let mkIntegrationGrpcServerEnv
    : Text
    = ''
        {
          "port":${G.unPort grpcPort},
          "sig_verify":true,
          "sig_header_name":"sig-bin",
          "tls_cert":"${tlsCert}",
          "tls_key":"${tlsKey}"
        }
      ''

let configMapEnv
    : List Text
    = [ env.integrationGrpcClientEnv
      , env.integrationElectrsEnv
      , env.integrationLndP2pHost
      , env.integrationLndP2pPort
      , env.integrationLogEnv
      , env.integrationLogFormat
      , env.integrationLogSeverity
      , env.integrationLogVerbosity
      , env.integrationMinChanCapMsat
      ]

let secretEnv
    : List Text
    = [ env.integrationGrpcServerEnv
      , env.integrationLndEnv
      , env.integrationLndEnv2
      , env.integrationLibpqConnStr
      , env.integrationBitcoindEnv
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

in  { env
    , mkService
    , mkDeployment
    , mkIntegrationBitcoindEnv
    , mkIntegrationGrpcServerEnv
    , mkIntegrationLndEnv
    }
