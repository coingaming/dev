let K = ../Kubernetes/Import.dhall

let G = ../Global.dhall

let Volume = ../Kubernetes/Volume.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Bitcoind

let image = "heathmont/bitcoind:v1.0.9"

let zmqPubRawBlockPort
    : G.Port
    = { unPort = 39703 }

let zmqPubRawTxPort
    : G.Port
    = { unPort = 39704 }

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
      G.unPort
      [ zmqPubRawBlockPort, zmqPubRawTxPort, mkRpcPort net ]

let mkServiceType
    : G.BitcoinNetwork → Service.ServiceType
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Service.ServiceType.LoadBalancer
          , TestNet = Service.ServiceType.LoadBalancer
          , RegTest = Service.ServiceType.ClusterIP
          }
          net

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
      Service.mkService owner (mkServiceType net) (Service.mkPorts (mkPorts net))

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
    = [ "CONFIG_FROM_ENV"
      , "DISABLEWALLET"
      , "PRUNE"
      , "REGTEST"
      , "RPCALLOWIP"
      , "RPCBIND"
      , "RPCPORT"
      , "SERVER"
      , "TESTNET"
      , "TXINDEX"
      , "ZMQPUBRAWBLOCK"
      , "ZMQPUBRAWTX"
      ]

let secretEnv
    : List Text
    = [ "RPCUSER", "RPCPASSWORD" ]

let env =
        Deployment.mkEnv Deployment.EnvVarType.ConfigMap owner configMapEnv
      # Deployment.mkEnv Deployment.EnvVarType.Secret owner secretEnv

let mkContainer
    : Text → G.BitcoinNetwork → K.Container.Type
    = λ(name : Text) →
      λ(net : G.BitcoinNetwork) →
        K.Container::{
        , name
        , image = Some image
        , env = Some env
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
    , mkRpcPort
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
