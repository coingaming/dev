#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/k8s-setup-minikube.sh"

minikube stop
