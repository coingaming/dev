let G = ../../Global.dhall

let S = ../../Service.dhall

let Bitcoind = ../../Service/Bitcoind.dhall

let network = G.BitcoinNetwork.MainNet

in  S.concatExportEnv (Bitcoind.mkEnv network)
