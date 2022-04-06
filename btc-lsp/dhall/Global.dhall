let P = ./Prelude/Import.dhall

let BitcoinNetwork
    : Type
    = < TestNet | RegTest | MainNet >

let unBitcoinNetwork
    : BitcoinNetwork → Text
    = λ(x : BitcoinNetwork) →
        merge
          { TestNet = "testnet", RegTest = "regtest", MainNet = "mainnet" }
          x

let NetworkScheme
    : Type
    = < Tcp | Http | Https >

let unNetworkScheme
    : NetworkScheme → Text
    = λ(x : NetworkScheme) →
        merge { Tcp = "tcp", Http = "http", Https = "https" } x

let HostName
    : Type
    = { unHostName : Text }

let Port
    : Type
    = { unPort : Natural }

let unPort
    : Port → Text
    = λ(x : Port) → Natural/show x.unPort

let unPorts
    : List Port → List Natural
    = λ(ports : List Port) →
        P.List.map Port Natural (λ(port : Port) → port.unPort) ports

let Owner
    : Type
    = < Bitcoind | Lsp | LndLsp | LndAlice | LndBob | Postgres | Rtl >

let unOwner
    : Owner → Text
    = λ(x : Owner) →
        merge
          { Bitcoind = "bitcoind"
          , Lsp = "lsp"
          , LndLsp = "lnd-lsp"
          , LndAlice = "lnd-alice"
          , LndBob = "lnd-bob"
          , Postgres = "postgres"
          , Rtl = "rtl"
          }
          x

let toLowerCase
    : Text → Text
    = λ(x : Text) → P.Text.lowerASCII x

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
              ++  toLowerCase x
              ++  "="
              ++  "\"${mkEnvVar x}\""
              ++  " \\"
          )
          ""

let defaultPass
    : Text
    = "developer"

let todo
    : Text
    = "TODO"

in  { BitcoinNetwork
    , unBitcoinNetwork
    , NetworkScheme
    , unNetworkScheme
    , HostName
    , Port
    , unPort
    , unPorts
    , Owner
    , unOwner
    , defaultPass
    , todo
    , toLowerCase
    , concatExportEnv
    , concatSetupEnv
    }
