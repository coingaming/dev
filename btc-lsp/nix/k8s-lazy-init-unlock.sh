#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

BITCOIN_NETWORK="$(sh "$THIS_DIR/k8s-get-env-var.sh" lnd BITCOIN_NETWORK)"
LND_WALLET_PASSWORD="$(sh "$THIS_DIR/k8s-get-secret.sh" lsp-secret lnd_wallet_password)"
LND_MACAROON_PATH="/root/.lnd/data/chain/bitcoin/$BITCOIN_NETWORK/admin.macaroon"

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

initWallet () {
  LND_SERVICE="$1"
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

  while kubectl exec \
  -i "$LND_POD" \
  -- sh \
  -c "[ ! -f $LND_MACAROON_PATH ]"
  do
   sleep 5
   echo "Waiting for wallet init..."
  done
}

createBtcWallet () {
  SERVICE="$1"
  BITCOIND_POD=`sh $THIS_DIR/k8s-get-pod.sh $SERVICE`
  ( echo "Create BTC Wallet of $BITCOIND_POD" \
    && kubectl exec \
        -it "$BITCOIND_POD" \
        -- bitcoin-cli \
        -rpcwait -$BITCOIN_NETWORK \
        createwallet "testwallet") || true

}

initWallet "lnd"

# if [ "$BITCOIN_NETWORK" = "regtest" ]; then
#   for OWNER in lnd-alice lnd-bob; do
#     initWallet "$OWNER"
#   done
#   createBtcWallet "bitcoind"
# fi

