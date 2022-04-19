let G = ../../Global.dhall

let Bitcoind = ../../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

in  G.concatExportEnv (Bitcoind.mkEnv network)
