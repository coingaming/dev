let K = ../Kubernetes/Import.dhall

let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let network = G.BitcoinNetwork.RegTest

in 
{ apiVersion = "v1"
, kind = "List"
, items = 
  [
    K.Resource.Service (Rtl.mkService network)
    , K.Resource.Ingress (Rtl.mkIngress network)
    , K.Resource.Deployment (Rtl.mkDeployment network)
  ]
}