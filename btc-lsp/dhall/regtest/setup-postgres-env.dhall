let G = ../Global.dhall

let Postgres = ../Service/Postgres.dhall

let owner = G.unOwner G.Owner.Postgres

let postgresMultipleDatabases = Postgres.env.postgresMultipleDatabases

let postgresDatabase = Postgres.env.postgresDatabase

let postgresUser = Postgres.env.postgresUser

let postgresPassword = Postgres.env.postgresPassword

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase
                         postgresMultipleDatabases}="${G.mkEnvVar
                                                         postgresDatabase}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase postgresUser}="${G.mkEnvVar
                                                        postgresUser}" \
      --from-literal=${G.toLowerCase
                         postgresPassword}="${G.mkEnvVar
                                                postgresPassword}") || true
    ''
