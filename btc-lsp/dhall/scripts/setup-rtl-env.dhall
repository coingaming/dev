let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let owner = G.unOwner G.Owner.Rtl

let configFromEnv = Rtl.env.configFromEnv

let rtlConfigNodesJson = Rtl.env.rtlConfigNodesJson

let rtlConfigJson = Rtl.env.rtlConfigJson

in  ''
    #!/bin/bash

    set -e

    THIS_DIR="$(dirname "$(realpath "$0")")"
    TLS_CERT_PATH="$THIS_DIR/../${owner}/tls.cert"
    TLS_KEY_PATH="$THIS_DIR/../${owner}/tls.key"

    . "$THIS_DIR/export-${owner}-env.sh"

    echo "==> Setting up env for ${owner}"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase
                         configFromEnv}="${G.mkEnvVar configFromEnv}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase
                         rtlConfigNodesJson}="${G.mkEnvVar
                                                  rtlConfigNodesJson}" \
      --from-literal=${G.toLowerCase
                         rtlConfigJson}="${G.mkEnvVar rtlConfigJson}") || true

    if [ -f "$TLS_CERT_PATH" ] && [ -f "$TLS_KEY_PATH" ]; then
      (kubectl create secret tls ${Rtl.tlsSecretName} \
        --cert="$TLS_CERT_PATH" \
        --key="$TLS_KEY_PATH") || true
    fi
    ''
