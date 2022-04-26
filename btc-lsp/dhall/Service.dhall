let P = ./Prelude/Import.dhall

let G = ./Global.dhall

let C = ./CloudProvider.dhall

let mkIngressAnnotations
    : G.BitcoinNetwork →
      Optional C.ProviderType →
      Text →
        Optional (P.Map.Type Text Text)
    = λ(net : G.BitcoinNetwork) →
      λ(cloudProvider : Optional C.ProviderType) →
      λ(certArn : Text) →
        let ingressAnnotations =
              P.Optional.concatMap
                C.ProviderType
                (P.Map.Type Text Text)
                (C.mkIngressAnnotations certArn)
                cloudProvider

        in  merge
              { MainNet = ingressAnnotations
              , TestNet = ingressAnnotations
              , RegTest = None (P.Map.Type Text Text)
              }
              net

let mkIngressClassName
    : Optional C.ProviderType → Optional Text
    = λ(cloudProvider : Optional C.ProviderType) →
        P.Optional.map C.ProviderType Text C.mkIngressClassName cloudProvider

let mkEnvVar
    : Text → Text
    = λ(name : Text) → "\$${name}"

let concatExportEnv
    : P.Map.Type Text Text → Text
    = λ(env : P.Map.Type Text Text) →
        P.List.foldLeft
          (P.Map.Entry Text Text)
          env
          Text
          ( λ(acc : Text) →
            λ(x : P.Map.Entry Text Text) →
              acc ++ "\n" ++ "export " ++ x.mapKey ++ "=" ++ x.mapValue
          )
          ''
          #!/bin/sh

          set -e
          ''

let concatSetupEnv
    : List Text → Text
    = λ(env : List Text) →
        P.List.foldLeft
          Text
          env
          Text
          ( λ(acc : Text) →
            λ(x : Text) →
                  acc
              ++  "\n"
              ++  "  --from-literal="
              ++  G.toLowerCase x
              ++  "="
              ++  "\"${mkEnvVar x}\""
              ++  " \\"
          )
          ""

in  { concatExportEnv
    , concatSetupEnv
    , mkIngressAnnotations
    , mkIngressClassName
    }
