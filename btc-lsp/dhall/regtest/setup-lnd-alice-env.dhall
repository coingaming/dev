let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

in  Lnd.mkSetupEnv G.Owner.LndAlice
