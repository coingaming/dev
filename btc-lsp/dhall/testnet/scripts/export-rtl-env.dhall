let G = ../../Global.dhall

let Rtl = ../../Service/Rtl.dhall

let network = G.BitcoinNetwork.TestNet

in  G.concatExportEnv (Rtl.mkEnv network [ G.Owner.Lnd ])
