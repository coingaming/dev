let G = ../../Global.dhall

let S = ../../Service.dhall

let Integration = ../../Service/Integration.dhall

let network = G.BitcoinNetwork.RegTest

in  S.concatExportEnv (Integration.mkEnv network)
