let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Volume = ../Kubernetes/Volume.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Bitcoind = ./Bitcoind.dhall

let image = "lightninglabs/lnd:v0.14.2-beta"

let tlsCert = ../../build/secrets/lnd/tls.cert as Text ? G.todo

let domain = ../../build/secrets/lnd/domain.txt as Text ? G.todo

let securePass = ../../build/secrets/lnd/walletpassword.txt as Text ? G.todo

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
      , lndWalletPass = "LND_WALLET_PASS"
      , bitcoinRpcUser = "BITCOIN_RPCUSER"
      , bitcoinRpcPass = "BITCOIN_RPCPASS"
      }

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
    = [ env.bitcoinRpcUser, env.bitcoinRpcPass, env.lndWalletPass ]

let ports
    : List Natural
    = G.unPorts [ grpcPort, p2pPort, restPort ]

let mkWalletPass
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
        merge
          { MainNet = domain
          , TestNet = domain
          , RegTest = G.unOwner G.Owner.Lnd
          }
          net

let mkHexMacaroon
    : G.Owner → Text
    = λ(owner : G.Owner) →
        merge
          { Lnd = ../../build/secrets/lnd/macaroon.hex as Text ? G.todo
          , LndAlice =
              ../../build/secrets/lnd-alice/macaroon.hex as Text ? G.todo
          , LndBob = ../../build/secrets/lnd-bob/macaroon.hex as Text ? G.todo
          , Bitcoind = G.todo
          , Lsp = G.todo
          , Postgres = G.todo
          , Rtl = G.todo
          }
          owner

let mkEnv
    : G.BitcoinNetwork → P.Map.Type Text Text
    = λ(net : G.BitcoinNetwork) →
        let networkScheme = G.unNetworkScheme G.NetworkScheme.Tcp

        let bitcoindHost = G.unOwner G.Owner.Bitcoind

        in  [ { mapKey = env.bitcoinDefaultChanConfs, mapValue = "1" }
            , { mapKey = env.bitcoinZmqPubRawBlock
              , mapValue =
                  "${networkScheme}://${bitcoindHost}:${G.unPort
                                                          Bitcoind.zmqPubRawBlockPort}"
              }
            , { mapKey = env.bitcoinZmqPubRawTx
              , mapValue =
                  "${networkScheme}://${bitcoindHost}:${G.unPort
                                                          Bitcoind.zmqPubRawTxPort}"
              }
            , { mapKey = env.lndGrpcPort, mapValue = G.unPort grpcPort }
            , { mapKey = env.lndP2pPort, mapValue = G.unPort p2pPort }
            , { mapKey = env.lndRestPort, mapValue = G.unPort restPort }
            , { mapKey = env.bitcoinNetwork, mapValue = G.unBitcoinNetwork net }
            , { mapKey = env.bitcoinRpcHost
              , mapValue =
                  "${bitcoindHost}:${G.unPort (Bitcoind.mkRpcPort net)}"
              }
            , { mapKey = env.lndWalletPass, mapValue = mkWalletPass net }
            , { mapKey = env.bitcoinRpcUser, mapValue = Bitcoind.mkRpcUser net }
            , { mapKey = env.bitcoinRpcPass, mapValue = Bitcoind.mkRpcPass net }
            ]

let mkSetupEnv
    : G.Owner → Text
    = λ(owner : G.Owner) →
        let ownerText = G.unOwner owner

        in  ''
            #!/bin/bash

            set -e

            THIS_DIR="$(dirname "$(realpath "$0")")"

            echo "==> Setting up env for ${ownerText}"

            . "$THIS_DIR/export-${G.unOwner G.Owner.Lnd}-env.sh"

            (
              kubectl create configmap ${ownerText} \${G.concatSetupEnv
                                                         configMapEnv}
            ) || true

            ( 
              kubectl create secret generic ${ownerText} \${G.concatSetupEnv
                                                              secretEnv}
            ) || true
            ''

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
          { MainNet =
              Service.mkAnnotations
                Service.CloudProvider.Aws
                (G.unOwner G.Owner.Lnd)
          , TestNet =
              Service.mkAnnotations
                Service.CloudProvider.DigitalOcean
                (G.unOwner G.Owner.Lnd)
          , RegTest = None (List { mapKey : Text, mapValue : Text })
          }
          net

let mkService
    : G.BitcoinNetwork → G.Owner → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
      λ(owner : G.Owner) →
        Service.mkService
          (G.unOwner owner)
          (mkServiceAnnotations net)
          (mkServiceType net)
          (Service.mkPorts ports)

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
    : G.BitcoinNetwork → G.Owner → K.PersistentVolumeClaim.Type
    = λ(net : G.BitcoinNetwork) →
      λ(owner : G.Owner) →
        Volume.mkPersistentVolumeClaim (G.unOwner owner) (mkVolumeSize net)

let mkContainerEnv
    : G.Owner → List K.EnvVar.Type
    = λ(owner : G.Owner) →
          Deployment.mkEnv
            Deployment.EnvVarType.ConfigMap
            (G.unOwner owner)
            configMapEnv
        # Deployment.mkEnv
            Deployment.EnvVarType.Secret
            (G.unOwner owner)
            secretEnv

let mkContainer
    : G.BitcoinNetwork → G.Owner → K.Container.Type
    = λ(net : G.BitcoinNetwork) →
      λ(owner : G.Owner) →
        K.Container::{
        , name = G.unOwner owner
        , image = Some image
        , args = Some
          [ "-c"
          , "lnd --bitcoin.active --bitcoin.\$\$BITCOIN_NETWORK --bitcoin.node=bitcoind --bitcoin.defaultchanconfs=\$\$BITCOIN_DEFAULTCHANCONFS --bitcoind.rpchost=\$\$BITCOIN_RPCHOST --bitcoind.rpcuser=\$\$BITCOIN_RPCUSER --bitcoind.rpcpass=\$\$BITCOIN_RPCPASS --bitcoind.zmqpubrawblock=\$\$BITCOIN_ZMQPUBRAWBLOCK --bitcoind.zmqpubrawtx=\$\$BITCOIN_ZMQPUBRAWTX --restlisten=0.0.0.0:\$\$LND_REST_PORT --rpclisten=0.0.0.0:\$\$LND_GRPC_PORT --listen=0.0.0.0:\$\$LND_P2P_PORT --maxpendingchannels=100 --protocol.wumbo-channels --coin-selection-strategy=random --accept-amp"
          ]
        , command = Some [ "sh" ]
        , env = Some (mkContainerEnv owner)
        , ports = Some (Deployment.mkContainerPorts ports)
        , volumeMounts = Some
          [ Deployment.mkVolumeMount (G.unOwner owner) "/root/.lnd" ]
        }

let mkDeployment
    : G.BitcoinNetwork → G.Owner → K.Deployment.Type
    = λ(net : G.BitcoinNetwork) →
      λ(owner : G.Owner) →
        Deployment.mkDeployment
          (G.unOwner owner)
          (Some K.DeploymentStrategy::{ type = Some "Recreate" })
          [ mkContainer net owner ]
          (Some [ Deployment.mkVolume (G.unOwner owner) ])

in  { tlsCert
    , grpcPort
    , p2pPort
    , restPort
    , mkDomain
    , mkHexMacaroon
    , mkEnv
    , mkSetupEnv
    , mkWalletPass
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
