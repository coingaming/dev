let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

in  Lnd.mkSetupScript G.Owner.LndLsp
