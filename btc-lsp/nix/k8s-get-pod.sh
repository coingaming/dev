#!/bin/sh

set -e

kubectl get pods \
  --no-headers \
  -o custom-columns=":metadata.name" \
  --selector=app.kubernetes.io/name="$1"
