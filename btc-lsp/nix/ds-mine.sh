#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
BITCOIN_NETWORK="regtest"

echo "$0 ==> starting"

if [ -z "$1" ]; then
  BLOCKS="1"
else
  BLOCKS="$1"
fi

for OWNER in lsp; do

  LND_SERVICE=yolo_lnd-$OWNER
  echo "$0 ==> getting LND_CONTAINER of $LND_SERVICE"
  LND_CONTAINER=`docker ps -f name=$LND_SERVICE --quiet`
  echo "$0 ==> getting $BITCOIN_NETWORK LND_ADDRESS of $LND_SERVICE $LND_CONTAINER"
  LND_ADDRESS=`docker exec \
    -it $LND_CONTAINER sh "-c" "lncli --network=$BITCOIN_NETWORK newaddress p2wkh | jq -r '.address'" \
    | tr -d '\r\n'`
  echo "$0 ==> got LND_ADDRESS $LND_ADDRESS of $LND_SERVICE"

  BITCOIND_SERVICE=yolo_bitcoind
  BITCOIND_CONTAINER=`docker ps -f name=$BITCOIND_SERVICE --quiet`
  echo "$BITCOIND_SERVICE ==> mining $BITCOIND_CONTAINER to $LND_ADDRESS"

  docker exec \
    -it "$BITCOIND_CONTAINER" bitcoin-cli \
    -rpcwait -$BITCOIN_NETWORK \
    generatetoaddress $BLOCKS $LND_ADDRESS 1>/dev/null

  echo "$BITCOIND_SERVICE ==> mined $BLOCKS blocks"

done
