let G = ../../Global.dhall

let S = ../../Service.dhall

let Rtl = ../../Service/Rtl.dhall

let network = G.BitcoinNetwork.TestNet

in  S.concatExportEnv (Rtl.mkEnv network [ G.Owner.Lnd ])
