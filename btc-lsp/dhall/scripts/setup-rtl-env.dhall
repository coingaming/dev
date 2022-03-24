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

    echo "==> Setting up env for ${owner}"

    source "$THIS_DIR/export-${owner}-env.sh"

    (kubectl create configmap ${owner} \
      --from-literal=${G.toLowerCase
                         configFromEnv}="${G.mkEnvVar configFromEnv}") || true

    (kubectl create secret generic ${owner} \
      --from-literal=${G.toLowerCase
                         rtlConfigNodesJson}="${G.mkEnvVar
                                                  rtlConfigNodesJson}" \
      --from-literal=${G.toLowerCase
                         rtlConfigJson}="${G.mkEnvVar rtlConfigJson}") || true

    (kubectl create secret tls ${Rtl.tlsSecretName} \
      --cert="$THIS_DIR/../${owner}/tls.crt" \
      --key="$THIS_DIR/../${owner}/tls.key") || true
    ''
