#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-export-env.sh"

minikube start --profile=$MINIKUBE_PROFILE

sh "$THIS_DIR/k8s-edit-conf.sh"

echo "==> Waiting until containers are ready"
sh "$THIS_DIR/k8s-wait.sh"
sleep 10

echo "==> Lazy init/unlock"
sh "$THIS_DIR/k8s-lazy-init-unlock.sh"
