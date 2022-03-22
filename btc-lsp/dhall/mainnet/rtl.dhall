let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Rtl = ../Service/Rtl.dhall

let network = G.BitcoinNetwork.MainNet

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Rtl.mkService network)
      , K.Resource.Ingress (Rtl.mkIngress network)
      , K.Resource.Deployment (Rtl.mkDeployment network)
      ]
    }
