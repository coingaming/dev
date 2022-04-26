let G = ../../Global.dhall

let C = ../../CloudProvider.dhall

let K = ../../Kubernetes/Import.dhall

let Lsp = ../../Service/Lsp.dhall

let network = G.BitcoinNetwork.MainNet

let cloudProvider = Some C.ProviderType.DigitalOcean

in  { apiVersion = "v1"
    , kind = "List"
    , items =
      [ K.Resource.Service (Lsp.mkService network cloudProvider)
      , K.Resource.Deployment (Lsp.mkDeployment network)
      ]
    }
