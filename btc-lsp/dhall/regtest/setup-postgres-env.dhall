let G = ../Global.dhall

let Postgres = ../Service/Postgres.dhall

let owner = G.unOwner G.Owner.Postgres

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (
      kubectl create configmap ${owner} \${G.concatSetupEnv
                                             Postgres.configMapEnv}
    ) || true

    (
      kubectl create secret generic ${owner} \${G.concatSetupEnv
                                                  Postgres.secretEnv}
    ) || true
    ''
