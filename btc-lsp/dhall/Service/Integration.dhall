let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let S = ../Service.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let Lsp = ../Service/Lsp.dhall

let owner = G.unOwner G.Owner.Integration

let image = ../../build/docker-image-integration.txt as Text ? G.todo

let env =
      { grpcClientEnv = "LSP_GRPC_CLIENT_ENV"
      , lndAliceEnv = "LND_ALICE_ENV"
      , lndBobEnv = "LND_BOB_ENV"
      }

let configMapEnv
    : List Text
    = [ env.grpcClientEnv ] # Lsp.configMapEnv

let secretEnv
    : List Text
    = [ env.lndAliceEnv, env.lndBobEnv ] # Lsp.secretEnv

let ports
    : List Natural
    = G.unPorts [ Lsp.grpcPort ]

let mkEnv
    : G.BitcoinNetwork → P.Map.Type Text Text
    = λ(net : G.BitcoinNetwork) →
          [ { mapKey = env.grpcClientEnv
            , mapValue = "'${P.JSON.render Lsp.mkLspGrpcClientEnv}'"
            }
          , { mapKey = env.lndAliceEnv
            , mapValue =
                "'${P.JSON.render (Lsp.mkLndEnv net G.Owner.LndAlice)}'"
            }
          , { mapKey = env.lndBobEnv
            , mapValue = "'${P.JSON.render (Lsp.mkLndEnv net G.Owner.LndBob)}'"
            }
          ]
        # Lsp.mkEnv net

let mkSetupEnv
    : G.Owner → Text
    = λ(owner : G.Owner) →
        let ownerText = G.unOwner owner

        in  ''
            #!/bin/bash

            set -e

            THIS_DIR="$(dirname "$(realpath "$0")")"

            . "$THIS_DIR/export-${ownerText}-env.sh"

            echo "==> Setting up env for ${ownerText}"

            (
              kubectl create configmap ${ownerText} \${S.concatSetupEnv
                                                         configMapEnv}
            ) || true

            (
              kubectl create secret generic ${ownerText} \${S.concatSetupEnv
                                                              secretEnv}
            ) || true
            ''

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

in  { mkEnv, mkSetupEnv, mkService, mkDeployment }
