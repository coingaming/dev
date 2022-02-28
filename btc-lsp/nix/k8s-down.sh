#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/k8s-export-env.sh"

minikube stop --profile=$MINIKUBE_PROFILE
