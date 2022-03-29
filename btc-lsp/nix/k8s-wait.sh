#!/bin/sh

set -e

check_state () {
  echo "Waiting till $1 is up and running..."
  kubectl wait pod \
    --for condition=ready \
    --timeout=300s \
    --selector=name=$1
  echo "Success! $1 is up and running!"
}

for MEMBER in bitcoind lnd rtl postgres; do
  check_state "$MEMBER"
done
