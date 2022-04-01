#!/bin/bash

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

sh "$THIS_DIR/k8s-get-secret.sh" "rtl" "rtl_config_json" "multiPass"
