#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/mk-setup-profile.sh"

echo "==> Drop old kubernetes cluster"
minikube stop && minikube delete

echo "==> Create new kubernetes cluster"
minikube start \
  --driver=docker \
  --apiserver-names=kubernetes.docker.internal \
  --mount --mount-string="$HOME:$HOME"

echo "==> Enable ingress addon"
minikube addons enable ingress

echo "==> Setup hosts to access services from localhost"
CLUSTER_IP=`minikube ip`
sudo sh "$THIS_DIR/mk-setup-hosts.sh" "$CLUSTER_IP"

echo "==> Allow to use kubectl from nix-shell"
sh "$THIS_DIR/mk-setup-kubeconf.sh"

echo "==> Cluster is ready for deployments!"
