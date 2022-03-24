let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Volume = ../Kubernetes/Volume.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Lnd

let image = "lightninglabs/lnd:v0.14.2-beta"

let walletPass = G.defaultPass

let hexMacaroon = ../../build/lnd/macaroon.hex as Text ? G.todo

let tlsCert = ../../build/lnd/tls.cert as Text ? G.todo

let minChanSize = 20000000

let grpcPort
    : G.Port
    = { unPort = 10009 }

let p2pPort
    : G.Port
    = { unPort = 9735 }

let restPort
    : G.Port
    = { unPort = 8080 }

let env =
      { bitcoinDefaultChanConfs = "BITCOIN_DEFAULTCHANCONFS"
      , bitcoinNetwork = "BITCOIN_NETWORK"
      , bitcoinRpcHost = "BITCOIN_RPCHOST"
      , bitcoinZmqPubRawBlock = "BITCOIN_ZMQPUBRAWBLOCK"
      , bitcoinZmqPubRawTx = "BITCOIN_ZMQPUBRAWTX"
      , lndGrpcPort = "LND_GRPC_PORT"
      , lndP2pPort = "LND_P2P_PORT"
      , lndRestPort = "LND_REST_PORT"
      , bitcoinRpcUser = "BITCOIN_RPCUSER"
      , bitcoinRpcPass = "BITCOIN_RPCPASS"
      }

let ports
    : List Natural
    = G.unPorts [ grpcPort, p2pPort, restPort ]

let mkHost
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = "lnd.coins.io"
          , TestNet = "testnet-lnd.coins.io"
          , RegTest = owner
          }
          net

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

let mkVolumeSize
    : G.BitcoinNetwork → Volume.Size.Type
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Volume.Size::{
            , capacity = 100
            , suffix = Volume.Suffix.Gigabyte
            }
          , TestNet = Volume.Size::{
            , capacity = 10
            , suffix = Volume.Suffix.Gigabyte
            }
          , RegTest = Volume.Size::{
            , capacity = 100
            , suffix = Volume.Suffix.Megabyte
            }
          }
          net

let mkPersistentVolumeClaim
    : G.BitcoinNetwork → K.PersistentVolumeClaim.Type
    = λ(net : G.BitcoinNetwork) →
        Volume.mkPersistentVolumeClaim owner (mkVolumeSize net)

let configMapEnv
    : List Text
    = [ env.bitcoinDefaultChanConfs
      , env.bitcoinNetwork
      , env.bitcoinRpcHost
      , env.bitcoinZmqPubRawBlock
      , env.bitcoinZmqPubRawTx
      , env.lndGrpcPort
      , env.lndP2pPort
      , env.lndRestPort
      ]

let secretEnv
    : List Text
    = [ env.bitcoinRpcUser, env.bitcoinRpcPass ]

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
        , args = Some
          [ "-c"
          , "lnd --bitcoin.active --bitcoin.\$\$BITCOIN_NETWORK --bitcoin.node=bitcoind --bitcoin.defaultchanconfs=\$\$BITCOIN_DEFAULTCHANCONFS --bitcoind.rpchost=\$\$BITCOIN_RPCHOST --bitcoind.rpcuser=\$\$BITCOIN_RPCUSER --bitcoind.rpcpass=\$\$BITCOIN_RPCPASS --bitcoind.zmqpubrawblock=\$\$BITCOIN_ZMQPUBRAWBLOCK --bitcoind.zmqpubrawtx=\$\$BITCOIN_ZMQPUBRAWTX --restlisten=0.0.0.0:\$\$LND_REST_PORT --rpclisten=0.0.0.0:\$\$LND_GRPC_PORT --listen=0.0.0.0:\$\$LND_P2P_PORT --maxpendingchannels=100"
          ]
        , command = Some [ "sh" ]
        , env = Some mkContainerEnv
        , ports = Some (Deployment.mkContainerPorts ports)
        , volumeMounts = Some [ Deployment.mkVolumeMount owner "/root/.lnd" ]
        }

let mkDeployment
    : G.BitcoinNetwork → K.Deployment.Type
    = λ(net : G.BitcoinNetwork) →
        Deployment.mkDeployment
          owner
          (Some K.DeploymentStrategy::{ type = Some "Recreate" })
          [ mkContainer owner net ]
          (Some [ Deployment.mkVolume owner ])

in  { walletPass
    , hexMacaroon
    , tlsCert
    , minChanSize
    , grpcPort
    , p2pPort
    , restPort
    , env
    , mkHost
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
