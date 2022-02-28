#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
KUBERNETES_DIR="$THIS_DIR/../build/kubernetes"
STACK=$1

if [ -z "$STACK" ]; then
  STACKS=`ls $KUBERNETES_DIR`
  echo "STACK must be one of:\n$STACKS"
else
  kubectl apply -f "$KUBERNETES_DIR/$STACK"
fi
