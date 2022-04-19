#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK=`sh $THIS_DIR/k8s-get-config.sh lnd bitcoin_network`
LND_ALICE_PUBKEY=$(cat $THIS_DIR/../build/secrets/lnd-alice/pubkey.hex)
LND_BOB_PUBKEY=$(cat $THIS_DIR/../build/secrets/lnd-bob/pubkey.hex)

echo "$0 ==> starting"

connectPeer () {
  local SERVICE_NAME="$1"
  local PEER_ADDRESS="$2"
  local LND_POD=`sh $THIS_DIR/k8s-get-pod.sh $SERVICE_NAME`

  echo "==> Connecting $LND_POD to $PEER_ADDRESS"

  kubectl exec \
    -it "$LND_POD" \
    -- sh "-c" "lncli --network=$BITCOIN_NETWORK connect $PEER_ADDRESS"
}

(connectPeer "lnd" "$LND_ALICE_PUBKEY@lnd-alice:9735") || true
(connectPeer "lnd" "$LND_BOB_PUBKEY@lnd-bob:9735") || true
