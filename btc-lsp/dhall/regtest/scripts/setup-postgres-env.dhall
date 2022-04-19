let G = ../../Global.dhall

let Postgres = ../../Service/Postgres.dhall

in  Postgres.mkSetupEnv G.Owner.Postgres
