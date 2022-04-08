let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

in  Bitcoind.mkSetupEnv G.Owner.Bitcoind
