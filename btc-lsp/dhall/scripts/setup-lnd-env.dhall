let G = ../Global.dhall

let Lnd = ../Service/Lnd.dhall

let owner = G.unOwner G.Owner.Lnd

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    echo "==> Setting up env for ${owner}"

    . "$THIS_DIR/export-${owner}-env.sh"

    (
      kubectl create configmap ${owner} \${G.concatEnv Lnd.configMapEnv}
    ) || true

    ( 
      kubectl create secret generic ${owner} \${G.concatEnv Lnd.secretEnv}
    ) || true
    ''
