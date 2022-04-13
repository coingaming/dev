let G = ../../Global.dhall

let Postgres = ../../Service/Postgres.dhall

in  G.concatExportEnv Postgres.mkEnv
