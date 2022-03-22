let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Lnd = ../Service/Lnd.dhall

let network = G.BitcoinNetwork.MainNet

in 
{ apiVersion = "v1"
, kind = "List"
, items = 
  [
    K.Resource.Service (Lnd.mkService network)
    , K.Resource.PersistentVolumeClaim (Lnd.mkPersistentVolumeClaim network)
    , K.Resource.Deployment (Lnd.mkDeployment network)
  ]
}
