let K = ../k8s/Import.dhall

let G = ../Global.dhall

let Volume = ../k8s/Volume.dhall

let Service = ../k8s/Service.dhall

let Deployment = ../k8s/Deployment.dhall

let owner = G.unOwner G.Owner.LndLsp

let image = "lightninglabs/lnd:v0.14.2-beta"

let grpcPort
    : G.Port
    = { unPort = 10009 }

let p2pPort
    : G.Port
    = { unPort = 9735 }

let restPort
    : G.Port
    = { unPort = 8080 }

let ports 
  : List Natural
  = G.unPort [ grpcPort, p2pPort, restPort ]

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
    = [ "BITCOIN_DEFAULTCHANCONFS"
      , "BITCOIN_NETWORK"
      , "BITCOIN_RPCHOST"
      , "BITCOIN_ZMQPUBRAWBLOCK"
      , "BITCOIN_ZMQPUBRAWTX"
      , "LND_GRPC_PORT"
      , "LND_P2P_PORT"
      , "LND_REST_PORT"
      ]

let secretEnv
    : List Text
    = [ "BITCOIN_RPCUSER", "BITCOIN_RPCPASS" ]

let env =
        Deployment.mkEnv Deployment.EnvVarType.ConfigMap owner configMapEnv
      # Deployment.mkEnv Deployment.EnvVarType.Secret (G.unOwner G.Owner.Bitcoind) secretEnv

let mkContainer
    : Text → G.BitcoinNetwork → K.Container.Type
    = λ(name : Text) →
      λ(net : G.BitcoinNetwork) →
        K.Container::{
        , name
        , image = Some image
        , env = Some env
        , ports = Some (Deployment.mkContainerPorts ports)
        , volumeMounts = Some
          [ Deployment.mkVolumeMount owner "/root/.lnd" ]
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
    , grpcPort
    , p2pPort
    , restPort
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
