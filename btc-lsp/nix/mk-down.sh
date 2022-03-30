#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/mk-setup-profile.sh"

minikube stop
