let G = ../Global.dhall

let Lsp = ../Service/Lsp.dhall

let owner = G.unOwner G.Owner.Lsp

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"

    . "$THIS_DIR/export-${owner}-env.sh"

    echo "==> Setting up env for ${owner}"

    (
      kubectl create configmap ${owner} \${G.concatEnv Lsp.configMapEnv}
    ) || true

    (
      kubectl create secret generic ${owner} \${G.concatEnv Lsp.secretEnv}
    ) || true
    ''
