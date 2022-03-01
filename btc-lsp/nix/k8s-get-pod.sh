#!/bin/sh

set -e

kubectl get pods --no-headers -o custom-columns=":metadata.name" --selector=io.kompose.service=$1
