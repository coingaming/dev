#!/bin/sh

set -e

SERVICE="$1"
FIELD="$2"

kubectl get configmap "$SERVICE" \
  -o "go-template={{index .data \"$FIELD\"}}"
