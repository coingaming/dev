let K = ./Kubernetes/Import.dhall

let name = "rtl"

let deployment =
      K.Deployment::{
      , metadata = K.ObjectMeta::{ name = Some name }
      , spec = Some K.DeploymentSpec::{
        , selector = K.LabelSelector::{ matchLabels = Some (toMap { name }) }
        , replicas = Some 1
        , template = K.PodTemplateSpec::{
          , metadata = Some K.ObjectMeta::{
            , labels = Some [ { mapKey = "name", mapValue = name } ]
            }
          , spec = Some K.PodSpec::{
            , containers =
              [ K.Container::{
                , name
                , image = Some "heathmont/rtl:9c8d7d6"
                , env = Some
                  [ K.EnvVar::{ name = "CONFIG_FROM_ENV", value = Some "true" }
                  , K.EnvVar::{
                    , name = "RTL_CONFIG_JSON"
                    , value = Some
                        ''
                        {
                          "SSO":{
                            "logoutRedirectLink": "",
                            "rtlCookiePath": "",
                            "rtlSSO": 0
                          },
                          "defaultNodeIndex": 1,
                          "multiPass": "developer",
                          "nodes": [],
                          "port": "80"
                        }
                        ''
                    }
                  , K.EnvVar::{
                    , name = "RTL_CONFIG_NODES_JSON"
                    , value = Some
                        ''
                        [
                          {
                            "hexMacaroon": "${  ../build/swarm/lnd-lsp/macaroon-regtest.hex as Text
                                              ? "TODO"}",
                            "index": 1,
                            "lnServerUrl": "https://lnd-lsp:8080"
                          }
                        ]
                        ''
                    }
                  ]
                , ports = Some [ K.ContainerPort::{ containerPort = 80 } ]
                }
              ]
            , hostname = Some name
            , restartPolicy = Some "Always"
            }
          }
        }
      }

in  deployment
