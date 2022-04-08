#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
KUBERNETES_DIR="$THIS_DIR/../build/k8s"
SERVICES="$1"

if [ -n "$SERVICES" ]; then
  for SERVICE in $SERVICES; do
    kubectl apply -f "$KUBERNETES_DIR/$SERVICE.yml"
  done
else
  kubectl apply -f "$KUBERNETES_DIR"
fi
