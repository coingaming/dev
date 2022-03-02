#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
POD=`sh $THIS_DIR/k8s-get-pod.sh $1`

kubectl logs $POD -f --tail 100
