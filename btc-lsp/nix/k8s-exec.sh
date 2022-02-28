#!/bin/sh

set -e

POD=`kubectl get pods --no-headers -o custom-columns=":metadata.name" --selector=io.kompose.service=$1`

kubectl exec --stdin --tty $POD -- $2
