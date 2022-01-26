#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

echo "==> Swarm file verification"
docker-compose \
  -f "$THIS_DIR/../build/docker-compose.yolo.yml" \
  config 1>/dev/null

echo "==> Swarm file deploy"
docker stack deploy \
  --with-registry-auth \
  -c "$THIS_DIR/../build/docker-compose.yolo.yml" yolo

echo "==> Waiting for the spawn"
sleep 10

echo "==> Lazy init/unlock"

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

  LND_SERVICE=yolo_lnd-$OWNER
  LND_CONTAINER=`docker ps -f name=$LND_SERVICE --quiet`
  ( echo "$LND_SERVICE ==> Checking wallet of $LND_CONTAINER" \
    && docker exec \
        -it $LND_CONTAINER lncli \
        --network=$BITCOIN_NETWORK getinfo ) \
  || ( echo "$LND_SERVICE ==> Unlocking wallet $LND_CONTAINER" \
       && echo "$LND_WALLET_PASSWORD" | docker exec \
        -i $LND_CONTAINER lncli \
        --network=$BITCOIN_NETWORK unlock \
        --stdin ) \
  || ( echo "$LND_SERVICE ==> Creating wallet $LND_CONTAINER" \
       && create_wallet \
        "docker exec -it $LND_CONTAINER lncli --network=$BITCOIN_NETWORK create" ) \
  || true

done
