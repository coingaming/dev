let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

in  Rtl.mkSetupEnv G.Owner.Rtl
