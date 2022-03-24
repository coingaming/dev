#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Drop old kubernetes cluster"
minikube stop --profile="$MINIKUBE_PROFILE" && \
minikube delete --profile="$MINIKUBE_PROFILE"

echo "==> Create new kubernetes cluster"
minikube start \
  --profile="$MINIKUBE_PROFILE" \
  --driver=docker \
  --apiserver-names=host.docker.internal \
  --mount --mount-string="$HOME:$HOME"

echo "==> Enable ingress addon"
minikube addons enable ingress --profile="$MINIKUBE_PROFILE"

echo "==> Setup hosts to access services from localhost"
CLUSTER_IP=`minikube ip --profile=$MINIKUBE_PROFILE`
sudo sh "$THIS_DIR/k8s-setup-hosts.sh" "$CLUSTER_IP"

echo "==> Allow to use kubectl from nix-shell"
sh "$THIS_DIR/k8s-edit-conf.sh"

echo "==> Cluster is ready for deployments!"
