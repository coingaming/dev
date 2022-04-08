let G = ../../Global.dhall

let Lnd = ../../Service/Lnd.dhall

let network = G.BitcoinNetwork.TestNet

in  G.concatExportEnv (Lnd.mkEnv network)
