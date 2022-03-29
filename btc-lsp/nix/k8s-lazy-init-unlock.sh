#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

BITCOIN_NETWORK=`sh $THIS_DIR/k8s-get-config.sh lnd bitcoin_network`
LND_WALLET_PASSWORD=`sh $THIS_DIR/k8s-get-secret.sh lsp lsp_lnd_env lnd_wallet_password`

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

  LND_SERVICE="lnd"
  LND_POD=`sh $THIS_DIR/k8s-get-pod.sh $LND_SERVICE`
  ( echo "$LND_SERVICE ==> Checking wallet of $LND_POD" \
    && kubectl exec \
        -i "$LND_POD" \
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
