let G = ../../Global.dhall

let C = ../../CloudProvider.dhall

let K = ../../Kubernetes/Import.dhall

let Lnd = ../../Service/Lnd.dhall

let network = G.BitcoinNetwork.MainNet

let owner = G.Owner.Lnd

let cloudProvider = Some C.ProviderType.Aws

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Lnd.mkService network owner cloudProvider)
      , K.Resource.PersistentVolumeClaim
          (Lnd.mkPersistentVolumeClaim network owner)
      , K.Resource.Deployment (Lnd.mkDeployment network owner)
      ]
    }
