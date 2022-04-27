#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

echo "$0 ==> starting"

. "$THIS_DIR/ns-export-test-envs.sh"

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
  for OWNER in lsp alice bob; do

    CURRENT_BLOCK=$(( CURRENT_BLOCK + BLOCKS2MINE ))
    LND_ADDRESS=`lncli_$OWNER newaddress p2wkh | jq -r '.address' | tr -d '\r\n'`
    echo "$OWNER ==> got LND_ADDRESS $LND_ADDRESS"
    bitcoin-cli generatetoaddress $BLOCKS2MINE $LND_ADDRESS 1>/dev/null
    echo "$OWNER ==> mined $CURRENT_BLOCK blocks"

    if [ $ASKED_BLOCKS -lt 10 ] && [ $CURRENT_BLOCK -ge $ASKED_BLOCKS ]; then
      break
    fi

  done
done

echo "$BITCOIND_SERVICE ==> mined enough blocks"
