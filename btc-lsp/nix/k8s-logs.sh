#!/bin/sh

set -e

SERVICE="$1"
POD=`kubectl get pods --no-headers -o custom-columns=":metadata.name" --selector=io.kompose.service=$SERVICE`

kubectl logs $POD -f --tail 100
