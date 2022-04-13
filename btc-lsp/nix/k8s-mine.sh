#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK=`sh $THIS_DIR/k8s-get-config.sh lnd bitcoin_network`

echo "$0 ==> starting"

CURRENT_BLOCK=0
if [ -z "$1" ]; then
  ASKED_BLOCKS="6"
else
  ASKED_BLOCKS="$1"
fi

if [ $ASKED_BLOCKS -lt 10 ]; then
  BLOCKS2MINE=1
else
  BLOCKS2MINE=$ASKED_BLOCKS
fi

while [ $CURRENT_BLOCK -lt $ASKED_BLOCKS ]; do
  for OWNER in lnd lnd-alice lnd-bob; do

    CURRENT_BLOCK=$(( CURRENT_BLOCK + BLOCKS2MINE ))

    LND_SERVICE="$OWNER"
    echo "$0 ==> getting LND_POD of $LND_SERVICE"
    LND_POD=`sh $THIS_DIR/k8s-get-pod.sh $LND_SERVICE`
    echo "$0 ==> getting $BITCOIN_NETWORK LND_ADDRESS of $LND_SERVICE $LND_POD"
    LND_ADDRESS=`kubectl exec \
      -it $LND_POD -- sh "-c" "lncli --network=$BITCOIN_NETWORK newaddress p2wkh | jq -r '.address'" \
      | tr -d '\r\n'`
    echo "$0 ==> got LND_ADDRESS $LND_ADDRESS of $LND_SERVICE"

    BITCOIND_SERVICE="bitcoind"
    BITCOIND_POD=`sh $THIS_DIR/k8s-get-pod.sh $BITCOIND_SERVICE`
    echo "$BITCOIND_SERVICE ==> mining $BITCOIND_POD to $LND_ADDRESS"

    kubectl exec \
      -it "$BITCOIND_POD" \
      -- bitcoin-cli \
      -rpcwait -$BITCOIN_NETWORK \
      generatetoaddress $BLOCKS2MINE $LND_ADDRESS 1>/dev/null

    echo "$BITCOIND_SERVICE ==> mined $CURRENT_BLOCK blocks"

    if [ $ASKED_BLOCKS -lt 10 ] && [ $CURRENT_BLOCK -ge $ASKED_BLOCKS ]; then
      break
    fi

  done
done

echo "$BITCOIND_SERVICE ==> mined enough blocks"
