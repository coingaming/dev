let K = ../k8s/Import.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let LndLsp = ../Service/LndLsp.dhall

let network = Bitcoind.BitcoinNetwork.TestNet

in 
{ apiVersion = "v1"
, kind = "List"
, items = 
  [
    K.Resource.Service (LndLsp.mkService network)
    , K.Resource.PersistentVolumeClaim (LndLsp.mkPersistentVolumeClaim network)
    , K.Resource.Deployment (LndLsp.mkDeployment network)
  ]
}
