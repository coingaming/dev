let G = ../../Global.dhall

let Integration = ../../Service/Integration.dhall

in  Integration.mkSetupEnv G.Owner.Integration
