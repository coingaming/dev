#!/bin/sh

set -e

SERVICE="$1"
FIELD="$2"
SUBFIELD="$3"

if [ -z "$3" ]; then
  kubectl get secret "$SERVICE" \
    -o "go-template={{index .data \"$FIELD\"}}" \
    | base64 -d
else
  kubectl get secret "$SERVICE" \
    -o "go-template={{index .data \"$FIELD\"}}" \
    | base64 -d \
    | jq -r ".$SUBFIELD" \
    | tr -d "\r\n"
fi
