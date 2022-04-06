let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let network = G.BitcoinNetwork.RegTest

in  G.concatExportEnv
      (Rtl.mkEnv network [ G.Owner.LndLsp, G.Owner.LndAlice, G.Owner.LndBob ])
