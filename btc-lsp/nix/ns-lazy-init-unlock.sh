#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
LND_WALLET_PASSWORD=developer

. "$THIS_DIR/ns-export-test-envs.sh"

createWallet() {
expect <<- EOF
  spawn sh -c "$(eval "echo \$lncli_src_$1") create";
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

lazyInitUnlock () {
  OWNER="$1"
  ( echo "$OWNER ==> Checking Lnd wallet" \
    && lncli_$OWNER getinfo ) \
  || ( echo "$OWNER ==> Unlocking Lnd wallet" \
       echo $LND_WALLET_PASSWORD | \
       lncli_$OWNER unlock --stdin ) \
  || ( echo "$OWNER ==> Creating Lnd wallet" \
       && createWallet $OWNER ) \
  || true
}

for OWNER in lsp alice bob; do
  lazyInitUnlock $OWNER
done
