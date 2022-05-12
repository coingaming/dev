let G = ../../Global.dhall

let C = ../../CloudProvider.dhall

let K = ../../Kubernetes/Import.dhall

let Bitcoind = ../../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.TestNet

let cloudProvider = Some C.ProviderType.Aws

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Bitcoind.mkService network cloudProvider)
      , K.Resource.PersistentVolumeClaim
          (Bitcoind.mkPersistentVolumeClaim network)
      , K.Resource.Deployment (Bitcoind.mkDeployment network)
      ]
    }
