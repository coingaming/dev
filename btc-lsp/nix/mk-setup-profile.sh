#!/bin/sh

set -e


THIS_DIR="$(dirname "$(realpath "$0")")"

. "$THIS_DIR/mk-export-profile.sh"

minikube profile "$MINIKUBE_PROFILE"
