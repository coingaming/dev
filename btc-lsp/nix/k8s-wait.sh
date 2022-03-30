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

SERVICES="$1"

if [ -n "$SERVICES" ]; then
  for SERVICE in $SERVICES; do
    check_state "$SERVICE"
  done
else
  echo "Specify services to wait for."
  exit 1;
fi
