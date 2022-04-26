let G = ../Global.dhall

let C = ../CloudProvider.dhall

let K = ../Kubernetes/Import.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.RegTest

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Bitcoind.mkService network (None C.ProviderType))
      , K.Resource.PersistentVolumeClaim
          (Bitcoind.mkPersistentVolumeClaim network)
      , K.Resource.Deployment (Bitcoind.mkDeployment network)
      ]
    }
