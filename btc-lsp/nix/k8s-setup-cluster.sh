#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-export-env.sh"

echo "==> Drop old kubernetes cluster"
minikube stop --profile=$MINIKUBE_PROFILE && \
minikube delete --profile=$MINIKUBE_PROFILE

echo "==> Create new kubernetes cluster"
minikube start \
--profile=$MINIKUBE_PROFILE \
--driver=docker \
--apiserver-names=host.docker.internal \
--mount --mount-string="$HOME:$HOME"

echo "==> Enable ingress addon"
minikube addons enable ingress --profile=$MINIKUBE_PROFILE

echo "==> Setup hosts to resolve ingress routes"
sudo sh "$THIS_DIR/k8s-setup-hosts.sh"

echo "==> Allow k8s to download images from private repos"
echo "DockerHub username:"
read DOCKERHUB_USERNAME

echo "DockerHub password:"
read -s DOCKERHUB_PASSWORD

echo "Checking if entered credentials are correct..."
docker login --username $DOCKERHUB_USERNAME --password $DOCKERHUB_PASSWORD

kubectl create secret docker-registry dockerhub \
--docker-username=$DOCKERHUB_USERNAME \
--docker-password=$DOCKERHUB_PASSWORD

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "dockerhub"}]}'

echo "==> Allow to use kubectl from nix-shell"
sh "$THIS_DIR/k8s-edit-conf.sh"

echo "==> Cluster is ready for deployments!"
