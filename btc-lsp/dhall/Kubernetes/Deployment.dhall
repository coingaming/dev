let P = ../Prelude/Import.dhall

let G = ../Global.dhall

let K = ./Import.dhall

let EnvVarType
    : Type
    = < Secret | ConfigMap >

let mkEnvVarSource
    : Text → EnvVarType → Text → K.EnvVarSource.Type
    = λ(key : Text) →
      λ(type : EnvVarType) →
      λ(source : Text) →
        merge
          { Secret = K.EnvVarSource::{
            , secretKeyRef = Some K.SecretKeySelector::{
              , key
              , name = Some source
              }
            }
          , ConfigMap = K.EnvVarSource::{
            , configMapKeyRef = Some K.ConfigMapKeySelector::{
              , key
              , name = Some source
              }
            }
          }
          type

let mkEnvVar
    : Text → EnvVarType → Text → K.EnvVar.Type
    = λ(name : Text) →
      λ(type : EnvVarType) →
      λ(source : Text) →
        let key = G.toLowerCase name

        in  K.EnvVar::{
            , name
            , valueFrom = Some (mkEnvVarSource key type source)
            }

let mkEnv
    : EnvVarType → Text → List Text → List K.EnvVar.Type
    = λ(type : EnvVarType) →
      λ(source : Text) →
      λ(vars : List Text) →
        P.List.map
          Text
          K.EnvVar.Type
          (λ(name : Text) → mkEnvVar name type source)
          vars

let mkVolumeMount
    : Text → Text → K.VolumeMount.Type
    = λ(name : Text) → λ(mountPath : Text) → K.VolumeMount::{ mountPath, name }

let mkVolume
    : Text → K.Volume.Type
    = λ(name : Text) →
        K.Volume::{
        , name
        , persistentVolumeClaim = Some K.PersistentVolumeClaimVolumeSource::{
          , claimName = name
          }
        }

let mkContainerPorts
    : List Natural → List K.ContainerPort.Type
    = λ(ports : List Natural) →
        P.List.map
          Natural
          K.ContainerPort.Type
          (λ(port : Natural) → K.ContainerPort::{ containerPort = port })
          ports

let mkDeployment
    : Text →
      Optional K.DeploymentStrategy.Type →
      List K.Container.Type →
      Optional (List K.Volume.Type) →
        K.Deployment.Type
    = λ(name : Text) →
      λ(strategy : Optional K.DeploymentStrategy.Type) →
      λ(containers : List K.Container.Type) →
      λ(volumes : Optional (List K.Volume.Type)) →
        K.Deployment::{
        , metadata = K.ObjectMeta::{ name = Some name }
        , spec = Some K.DeploymentSpec::{
          , selector = K.LabelSelector::{ matchLabels = Some (toMap { name }) }
          , replicas = Some 1
          , strategy
          , template = K.PodTemplateSpec::{
            , metadata = Some K.ObjectMeta::{
              , labels = Some [ { mapKey = "name", mapValue = name } ]
              }
            , spec = Some K.PodSpec::{
              , containers
              , hostname = Some name
              , restartPolicy = Some "Always"
              , volumes
              }
            }
          }
        }

in  { EnvVarType
    , mkDeployment
    , mkEnv
    , mkContainerPorts
    , mkVolumeMount
    , mkVolume
    }
