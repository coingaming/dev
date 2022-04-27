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

let Encryption
    : Type
    = < Encrypted | UnEncrypted >

let unEncryption
    : Encryption → Text
    = λ(x : Encryption) →
        merge { Encrypted = "Encrypted", UnEncrypted = "UnEncrypted" } x

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
    = < Bitcoind
      | Lsp
      | Lnd
      | LndAlice
      | LndBob
      | Postgres
      | Rtl
      | Integration
      >

let unOwner
    : Owner → Text
    = λ(x : Owner) →
        merge
          { Bitcoind = "bitcoind"
          , Lsp = "lsp"
          , Lnd = "lnd"
          , LndAlice = "lnd-alice"
          , LndBob = "lnd-bob"
          , Postgres = "postgres"
          , Rtl = "rtl"
          , Integration = "integration"
          }
          x

let toLowerCase
    : Text → Text
    = λ(x : Text) → P.Text.lowerASCII x

let defaultPass
    : Text
    = "developer"

let todo
    : Text
    = "TODO"

in  { BitcoinNetwork
    , unBitcoinNetwork
    , Encryption
    , unEncryption
    , NetworkScheme
    , unNetworkScheme
    , HostName
    , Port
    , unPort
    , unPorts
    , Owner
    , unOwner
    , toLowerCase
    , defaultPass
    , todo
    }
