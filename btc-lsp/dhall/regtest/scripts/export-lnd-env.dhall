let G = ../../Global.dhall

let S = ../../Service.dhall

let Lnd = ../../Service/Lnd.dhall

let network = G.BitcoinNetwork.RegTest

in  S.concatExportEnv (Lnd.mkEnv network)
