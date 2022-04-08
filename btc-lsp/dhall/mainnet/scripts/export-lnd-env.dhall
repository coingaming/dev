let G = ../../Global.dhall

let Lnd = ../../Service/Lnd.dhall

let network = G.BitcoinNetwork.MainNet

in  G.concatExportEnv (Lnd.mkEnv network)
