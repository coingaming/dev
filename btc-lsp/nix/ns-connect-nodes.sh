#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

echo "$0 ==> starting"

. "$THIS_DIR/ns-export-test-envs.sh"

getPubKey () {
  lncli_$1 getinfo | jq -r '.identity_pubkey' | tr -d '\r\n'
}

LSP_PUB=`getPubKey lsp`
LSP_CRED="$LSP_PUB@127.0.0.1:9736"

echo "$0 => Connecting to $LSP_CRED"
lncli_alice connect "$LSP_CRED"
lncli_bob connect "$LSP_CRED"
