let S = ../../Service.dhall

let Postgres = ../../Service/Postgres.dhall

in  S.concatExportEnv Postgres.mkEnv
