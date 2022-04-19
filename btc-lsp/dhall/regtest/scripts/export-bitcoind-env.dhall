let G = ../../Global.dhall

let Bitcoind = ../../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.RegTest

in  G.concatExportEnv (Bitcoind.mkEnv network)
