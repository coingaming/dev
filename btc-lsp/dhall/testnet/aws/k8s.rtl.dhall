let G = ../../Global.dhall

let K = ../../Kubernetes/Import.dhall

let Rtl = ../../Service/Rtl.dhall

let network = G.BitcoinNetwork.TestNet

let cloudProvider = G.CloudProvider.Aws

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Rtl.mkService network)
      , K.Resource.Ingress (Rtl.mkIngress network cloudProvider)
      , K.Resource.Deployment (Rtl.mkDeployment network)
      ]
    }
