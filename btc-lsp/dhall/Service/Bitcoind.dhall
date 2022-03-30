let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Volume = ../Kubernetes/Volume.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Bitcoind

let image = "heathmont/bitcoind:v0.22.0"

let zmqPubRawBlockPort
    : G.Port
    = { unPort = 39703 }

let zmqPubRawTxPort
    : G.Port
    = { unPort = 39704 }

let env =
      { configFromEnv = "CONFIG_FROM_ENV"
      , disableWallet = "DISABLEWALLET"
      , prune = "PRUNE"
      , regTest = "REGTEST"
      , rpcAllowIp = "RPCALLOWIP"
      , rpcBind = "RPCBIND"
      , rpcPort = "RPCPORT"
      , server = "SERVER"
      , testNet = "TESTNET"
      , txIndex = "TXINDEX"
      , zmqPubRawBlock = "ZMQPUBRAWBLOCK"
      , zmqPubRawTx = "ZMQPUBRAWTX"
      , rpcUser = "RPCUSER"
      , rpcPassword = "RPCPASSWORD"
      }

let mkRpcUser
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = ../../build/bitcoind/rpcuser.txt as Text
          , TestNet = ../../build/bitcoind/rpcuser.txt as Text
          , RegTest = "bitcoinrpc"
          }
          net

let mkRpcPass
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = ../../build/bitcoind/rpcpass.txt as Text
          , TestNet = ../../build/bitcoind/rpcpass.txt as Text
          , RegTest = G.defaultPass
          }
          net

let mkRpcPort
    : G.BitcoinNetwork → G.Port
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet.unPort = 8332
          , TestNet.unPort = 18332
          , RegTest.unPort = 18332
          }
          net

let mkPorts
    : G.BitcoinNetwork → List Natural
    = λ(net : G.BitcoinNetwork) →
        G.unPorts [ zmqPubRawBlockPort, zmqPubRawTxPort, mkRpcPort net ]

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
          (Service.mkPorts (mkPorts net))

let mkVolumeSize
    : G.BitcoinNetwork → Volume.Size.Type
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Volume.Size::{
            , capacity = 1
            , suffix = Volume.Suffix.Terabyte
            }
          , TestNet = Volume.Size::{
            , capacity = 100
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
    = [ env.configFromEnv
      , env.disableWallet
      , env.prune
      , env.regTest
      , env.rpcAllowIp
      , env.rpcBind
      , env.rpcPort
      , env.server
      , env.testNet
      , env.txIndex
      , env.zmqPubRawBlock
      , env.zmqPubRawTx
      ]

let secretEnv
    : List Text
    = [ env.rpcUser, env.rpcPassword ]

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
        , ports = Some (Deployment.mkContainerPorts (mkPorts net))
        , volumeMounts = Some
          [ Deployment.mkVolumeMount owner "/bitcoin/.bitcoin" ]
        }

let mkDeployment
    : G.BitcoinNetwork → K.Deployment.Type
    = λ(net : G.BitcoinNetwork) →
        Deployment.mkDeployment
          owner
          (Some K.DeploymentStrategy::{ type = Some "Recreate" })
          [ mkContainer owner net ]
          (Some [ Deployment.mkVolume owner ])

in  { 
    , zmqPubRawBlockPort
    , zmqPubRawTxPort
    , env
    , mkRpcUser
    , mkRpcPass
    , mkRpcPort
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
