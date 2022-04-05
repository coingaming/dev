let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let owner = G.unOwner G.Owner.Rtl

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"
    TLS_CERT_PATH="$THIS_DIR/../${owner}/tls.cert"
    TLS_KEY_PATH="$THIS_DIR/../${owner}/tls.key"

    . "$THIS_DIR/export-${owner}-env.sh"

    echo "==> Setting up env for ${owner}"

    (
      kubectl create configmap ${owner} \${G.concatSetupEnv Rtl.configMapEnv}
    ) || true

    (
      kubectl create secret generic ${owner} \${G.concatSetupEnv Rtl.secretEnv}
    ) || true

    if [ -f "$TLS_CERT_PATH" ] && [ -f "$TLS_KEY_PATH" ]; then
      (kubectl create secret tls ${Rtl.tlsSecretName} \
        --cert="$TLS_CERT_PATH" \
        --key="$TLS_KEY_PATH") || true
    fi
    ''
