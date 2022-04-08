let G = ../Global.dhall

let Integration = ../Service/Integration.dhall

let owner = G.unOwner G.Owner.Integration

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (
      kubectl create configmap ${owner} \${G.concatSetupEnv
                                             Integration.configMapEnv}
    ) || true

    (
      kubectl create secret generic ${owner} \${G.concatSetupEnv
                                                  Integration.secretEnv}
    ) || true
    ''
