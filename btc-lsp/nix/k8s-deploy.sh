#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
KUBERNETES_DIR="$THIS_DIR/../build/k8s"

kubectl apply -f "$KUBERNETES_DIR"
