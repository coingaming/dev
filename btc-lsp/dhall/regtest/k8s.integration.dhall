let G = ../Global.dhall

let K = ../Kubernetes/Import.dhall

let Integration = ../Service/Integration.dhall

let network = G.BitcoinNetwork.RegTest

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Integration.mkService network)
      , K.Resource.Deployment (Integration.mkDeployment network)
      ]
    }
