#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
KUBERNETES_DIR="$BUILD_DIR/kubernetes"

mkdir -p "$KUBERNETES_DIR"

for STACK in yolo; do
  for f in $BUILD_DIR/docker-compose.$STACK.yml; do
    STACK_DIR="$KUBERNETES_DIR/$STACK"
    mkdir -p "$STACK_DIR"
    kompose convert -f "$f" \
    --with-kompose-annotation=false \
    -o "$STACK_DIR";
  done
done
