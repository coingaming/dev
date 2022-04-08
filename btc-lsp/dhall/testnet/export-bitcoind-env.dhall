let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.TestNet

in  G.concatExportEnv (Bitcoind.mkEnv network)
