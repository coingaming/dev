let K = ../k8s/Import.dhall

let G = ../Global.dhall

let LndLsp = ../Service/LndLsp.dhall

let network = G.BitcoinNetwork.RegTest

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
