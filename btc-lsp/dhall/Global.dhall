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
    : List Port → List Natural
    = λ(ports : List Port) →
        P.List.map Port Natural (λ(port : Port) → port.unPort) ports

let Owner
    : Type
    = < Bitcoind | Lsp | Lnd | Postgres | Rtl >

let unOwner
    : Owner → Text
    = λ(x : Owner) →
        merge
          { Bitcoind = "bitcoind"
          , Lsp = "lsp"
          , Lnd = "lnd"
          , Postgres = "postgres"
          , Rtl = "rtl"
          }
          x

in  { BitcoinNetwork
    , unBitcoinNetwork
    , NetworkScheme
    , unNetworkScheme
    , HostName
    , Port
    , unPort
    , Owner
    , unOwner
    }
