let G = ../../Global.dhall

let Integration = ../../Service/Integration.dhall

let network = G.BitcoinNetwork.RegTest

in  G.concatExportEnv (Integration.mkEnv network)
