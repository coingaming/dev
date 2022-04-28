let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let S = ../Service.dhall

let K = ../Kubernetes/Import.dhall

let Service = ../Kubernetes/Service.dhall

let Volume = ../Kubernetes/Volume.dhall

let Deployment = ../Kubernetes/Deployment.dhall

let owner = G.unOwner G.Owner.Postgres

let image = "heathmont/postgres:11-alpine-a2e8bbe"

let userName = "lsp"

let password = G.defaultPass

let host = owner

let databaseName = userName

let databaseUri = ../../build/secrets/postgres/dburi.txt as Text ? G.todo

let tcpPort
    : G.Port
    = { unPort = 5432 }

let env =
      { postgresMultipleDatabases = "POSTGRES_MULTIPLE_DATABASES"
      , postgresUser = "POSTGRES_USER"
      , postgresPassword = "POSTGRES_PASSWORD"
      , postgresHost = "POSTGRES_HOST"
      , postgresDatabase = "POSTGRES_DATABASE"
      }

let configMapEnv
    : List Text
    = [ env.postgresMultipleDatabases ]

let secretEnv
    : List Text
    = [ env.postgresUser, env.postgresPassword ]

let mkConnStr
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = databaseUri
          , TestNet = databaseUri
          , RegTest =
              "postgresql://${userName}:${password}@${host}/${databaseName}"
          }
          net

let mkUser
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge { MainNet = G.todo, TestNet = G.todo, RegTest = userName } net

let mkPassword
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge { MainNet = G.todo, TestNet = G.todo, RegTest = password } net

let mkHost
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge { MainNet = G.todo, TestNet = G.todo, RegTest = host } net

let mkDatabaseName
    : G.BitcoinNetwork → Text
    = λ(net : G.BitcoinNetwork) →
        merge { MainNet = G.todo, TestNet = G.todo, RegTest = databaseName } net

let ports
    : List Natural
    = G.unPorts [ tcpPort ]

let mkEnv
    : P.Map.Type Text Text
    = [ { mapKey = env.postgresUser, mapValue = userName }
      , { mapKey = env.postgresPassword, mapValue = password }
      , { mapKey = env.postgresMultipleDatabases, mapValue = databaseName }
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

            . "$THIS_DIR/export-${ownerText}-env.sh"

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
          , RegTest = Service.ServiceType.ClusterIP
          }
          net

let mkService
    : G.BitcoinNetwork → K.Service.Type
    = λ(net : G.BitcoinNetwork) →
        Service.mkService
          owner
          (None (P.Map.Type Text Text))
          (mkServiceType net)
          (Service.mkPorts ports)

let mkVolumeSize
    : G.BitcoinNetwork → Volume.Size.Type
    = λ(net : G.BitcoinNetwork) →
        merge
          { MainNet = Volume.Size::{
            , capacity = 1
            , suffix = Volume.Suffix.Gigabyte
            }
          , TestNet = Volume.Size::{
            , capacity = 1
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
        , volumeMounts = Some
          [ Deployment.mkVolumeMount owner "/var/lib/postgresql/data" ]
        }

let mkDeployment
    : G.BitcoinNetwork → K.Deployment.Type
    = λ(net : G.BitcoinNetwork) →
        Deployment.mkDeployment
          owner
          (None K.DeploymentStrategy.Type)
          [ mkContainer owner net ]
          (Some [ Deployment.mkVolume owner ])

in  { mkEnv
    , mkSetupEnv
    , mkConnStr
    , mkUser
    , mkPassword
    , mkHost
    , mkDatabaseName
    , mkService
    , mkPersistentVolumeClaim
    , mkDeployment
    }
