let G = ../../Global.dhall

let Lsp = ../../Service/Lsp.dhall

let network = G.BitcoinNetwork.RegTest

in  G.concatExportEnv (Lsp.mkEnv network)
