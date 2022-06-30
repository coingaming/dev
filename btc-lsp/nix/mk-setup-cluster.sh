#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/mk-export-profile.sh"

echo "==> Drop old kubernetes cluster"
minikube stop && minikube delete

echo "==> Create new kubernetes cluster"
minikube start \
  --profile="$MINIKUBE_PROFILE" \
  --driver=docker

echo "==> Setting default minikube profile"
sh "$THIS_DIR/mk-setup-profile.sh"

echo "==> Enable ingress addon"
minikube addons enable ingress

echo "==> Setup hosts to access services from localhost"
CLUSTER_IP="$(minikube ip)"
sudo sh "$THIS_DIR/mk-setup-hosts.sh" "$CLUSTER_IP"

echo "==> Cluster is ready for deployments!"
