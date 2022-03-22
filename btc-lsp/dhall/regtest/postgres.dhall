let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Postgres = ../Service/Postgres.dhall

let network = G.BitcoinNetwork.RegTest

in 
{ apiVersion = "v1"
, kind = "List"
, items = 
  [
    K.Resource.Service (Postgres.mkService network)
    , K.Resource.PersistentVolumeClaim (Postgres.mkPersistentVolumeClaim network)
    , K.Resource.Deployment (Postgres.mkDeployment network)
  ]
}
