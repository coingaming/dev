let G = ../../Global.dhall

let C = ../../CloudProvider.dhall

let K = ../../Kubernetes/Import.dhall

let Rtl = ../../Service/Rtl.dhall

let network = G.BitcoinNetwork.TestNet

let cloudProvider = Some C.ProviderType.Aws

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Rtl.mkService network)
      , K.Resource.Ingress (Rtl.mkIngress network cloudProvider)
      , K.Resource.Deployment (Rtl.mkDeployment network)
      ]
    }
