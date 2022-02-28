#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

BITCOIN_NETWORK="regtest"
LND_WALLET_PASSWORD="developer"

create_wallet() {
expect <<- EOF
  spawn $1 create;
  expect "Input wallet password: ";
  send "$LND_WALLET_PASSWORD\r";
  expect "Confirm password: ";
  send "$LND_WALLET_PASSWORD\r";
  expect "Do you have";
  send "n\r";
  expect "Input your passphrase if ";
  send "\r";
  expect "lnd successfully initialized!";
  sleep 2;
  interact;
EOF
}

for OWNER in lsp; do

  LND_SERVICE="yolo-lnd-$OWNER"
  LND_POD=`kubectl get pods --no-headers -o custom-columns=":metadata.name" --selector=io.kompose.service=$LND_SERVICE`
  ( echo "$LND_SERVICE ==> Checking wallet of $LND_POD" \
    && kubectl exec \
        -it "$LND_POD" \ 
        -- lncli \
        --network="$BITCOIN_NETWORK" getinfo ) \
  || ( echo "$LND_SERVICE ==> Unlocking wallet $LND_POD" \
       && echo "$LND_WALLET_PASSWORD" | kubectl exec \
        -i "$LND_POD" \
        -- lncli \
        --network="$BITCOIN_NETWORK" unlock \
        --stdin ) \
  || ( echo "$LND_SERVICE ==> Creating wallet $LND_POD" \
       && create_wallet \
        "kubectl exec -it $LND_POD -- lncli --network=$BITCOIN_NETWORK create" ) \
  || true

done
