let G = ../Global.dhall

let Bitcoind = ../Service/Bitcoind.dhall

let owner = G.unOwner G.Owner.Bitcoind

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (
      kubectl create configmap ${owner} \${G.concatSetupEnv
                                             Bitcoind.configMapEnv}
    ) || true

    (
      kubectl create secret generic ${owner} \${G.concatSetupEnv
                                                  Bitcoind.secretEnv}
    ) || true
    ''
