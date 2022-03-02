#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK="regtest"

echo "$0 ==> starting"

if [ -z "$1" ]; then
  BLOCKS="6"
else
  BLOCKS="$1"
fi

for OWNER in lsp; do

  LND_SERVICE="lnd-$OWNER"
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
    generatetoaddress $BLOCKS $LND_ADDRESS 1>/dev/null

  echo "$BITCOIND_SERVICE ==> mined $BLOCKS blocks"

done
