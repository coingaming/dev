let G = ../../Global.dhall

let Lsp = ../../Service/Lsp.dhall

let network = G.BitcoinNetwork.TestNet

in  G.concatExportEnv (Lsp.mkEnv network)
