#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK=`sh $THIS_DIR/k8s-get-config.sh lnd bitcoin_network`
LND_ALICE_PUBKEY=$(cat $THIS_DIR/../build/secrets/lnd-alice/pubkey.hex)
LND_BOB_PUBKEY=$(cat $THIS_DIR/../build/secrets/lnd-bob/pubkey.hex)

if [ -z "$1" ]; then
  CHANNEL_CAPACITY="100000"
else
  CHANNEL_CAPACITY="$1"
fi

echo "$0 ==> starting"

openChannel () {
  local SERVICE_NAME="$1"
  local PUBKEY="$2"
  local CAPACITY="$3"

  local LND_POD=`sh $THIS_DIR/k8s-get-pod.sh $SERVICE_NAME`
  local PUSH_AMT=$(($CAPACITY / 2))

  echo "==> Opening channel between $LND_POD and $PUBKEY for $CAPACITY sats and pushing $PUSH_AMT sats"

  kubectl exec \
    -it "$LND_POD" \
    -- sh "-c" "lncli --network=$BITCOIN_NETWORK openchannel $PUBKEY $CAPACITY $PUSH_AMT"
}

sh "$THIS_DIR/k8s-connect-nodes.sh"

openChannel "lnd" "$LND_ALICE_PUBKEY" "$CHANNEL_CAPACITY"
openChannel "lnd" "$LND_BOB_PUBKEY" "$CHANNEL_CAPACITY"

sh "$THIS_DIR/k8s-mine.sh"
