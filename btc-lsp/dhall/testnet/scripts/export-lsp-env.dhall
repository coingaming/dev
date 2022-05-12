let G = ../../Global.dhall

let S = ../../Service.dhall

let Lsp = ../../Service/Lsp.dhall

let network = G.BitcoinNetwork.TestNet

in  S.concatExportEnv (Lsp.mkEnv network)
