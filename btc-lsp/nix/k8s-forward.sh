#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

BITCOIND_POD=`sh $THIS_DIR/k8s-get-pod.sh bitcoind`
LND_POD=`sh $THIS_DIR/k8s-get-pod.sh lnd`
LSP_POD=`sh $THIS_DIR/k8s-get-pod.sh lsp`
POSTGRES_POD=`sh $THIS_DIR/k8s-get-pod.sh postgres`

kubectl port-forward "$BITCOIND_POD" 18332:18332 39703:39703 39704:39704 &
kubectl port-forward "$LND_POD" 9735:9735 &
kubectl port-forward "$LSP_POD" 8443:8443 &
kubectl port-forward "$POSTGRES_POD" 5432:5432 &

PIDS=$(jobs -pr)

trap "kill -9 $PIDS; exit" SIGINT SIGKILL SIGTERM

wait $PIDS
