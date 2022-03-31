let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Bitcoind = ./Bitcoind.dhall

let Lnd = ./Lnd.dhall

let owner = G.unOwner G.Owner.Lsp

let tlsCert = ../../build/lsp/inlined-tls.cert as Text ? G.todo

let tlsKey = ../../build/lsp/inlined-tls.key as Text ? G.todo

let logEnv = "test"

let logFormat = "Bracket"

let logVerbosity = "V3"

let logSeverity = "DebugS"

let grpcPort
    : G.Port
    = { unPort = 8443 }

let env =
      { lspEndpointPort = "LSP_ENDPOINT_PORT"
      , lspLogEnv = "LSP_LOG_ENV"
      , lspLogFormat = "LSP_LOG_FORMAT"
      , lspLogVerbosity = "LSP_LOG_VERBOSITY"
      , lspLogSeverity = "LSP_LOG_SEVERITY"
      , lspLndP2pHost = "LSP_LND_P2P_HOST"
      , lspLndP2pPort = "LSP_LND_P2P_PORT"
      , lspLibpqConnStr = "LSP_LIBPQ_CONN_STR"
      , lspLndEnv = "LSP_LND_ENV"
      , lspGrpcServerEnv = "LSP_GRPC_SERVER_ENV"
      , lspBitcoindEnv = "LSP_BITCOIND_ENV"
      , lspMinChanCapMsat = "LSP_MIN_CHAN_CAP_MSAT"
      , lspMsatPerByte = "LSP_MSAT_PER_BYTE"
      }

let mkLspLndEnv
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

let mkLspBitcoindEnv
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

let mkLspGrpcServerEnv
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

let ports
    : List Natural
    = G.unPorts [ grpcPort ]

let mkServiceType
    : G.BitcoinNetwork → Service.ServiceType
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.ServiceType.LoadBalancer
          , TestNet = Service.ServiceType.LoadBalancer
          , RegTest = Service.ServiceType.ClusterIP
          }
          net

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

let mkContainerImage
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = "ghcr.io/coingaming/btc-lsp:v0.1.12"
          , TestNet = "ghcr.io/coingaming/btc-lsp:v0.1.12"
          , RegTest = ../../build/docker-image-btc-lsp.txt as Text ? G.todo
          }
          net

let configMapEnv
    : List Text
    = [ env.lspEndpointPort
      , env.lspLogEnv
      , env.lspLogFormat
      , env.lspLogVerbosity
      , env.lspLogSeverity
      , env.lspLndP2pHost
      , env.lspLndP2pPort
      , env.lspMinChanCapMsat
      , env.lspMsatPerByte
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
        , image = Some (mkContainerImage net)
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

in  { logEnv
    , logFormat
    , logVerbosity
    , logSeverity
    , grpcPort
    , env
    , mkLspLndEnv
    , mkLspBitcoindEnv
    , mkLspGrpcServerEnv
    , mkService
    , mkDeployment
    }
