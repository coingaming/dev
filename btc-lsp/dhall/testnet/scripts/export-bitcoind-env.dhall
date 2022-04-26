let G = ../../Global.dhall

let S = ../../Service.dhall

let Bitcoind = ../../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.TestNet

in  S.concatExportEnv (Bitcoind.mkEnv network)
