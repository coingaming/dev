#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SERVICE_NAME="$1"
ENV_VAR="$2"
NAMESPACE="${3:-default}"
POD="$(sh "$THIS_DIR/k8s-get-pod.sh" "$SERVICE_NAME" "$NAMESPACE")"

kubectl exec "$POD" \
  -n "$NAMESPACE" \
  -- printenv "$ENV_VAR"
