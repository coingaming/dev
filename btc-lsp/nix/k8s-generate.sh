#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
KUBERNETES_DIR="$BUILD_DIR/kubernetes"

mkdir -p "$KUBERNETES_DIR"

for STACK in yolo; do
  STACK_DIR="$KUBERNETES_DIR/$STACK"

  for f in $BUILD_DIR/docker-compose.$STACK.yml; do
    mkdir -p "$STACK_DIR"
    kompose convert -f "$f" \
    --with-kompose-annotation=false \
    -o "$STACK_DIR";
  done

  for FILENAME in docker-proxy-deployment.yaml docker-proxy-service.yaml; do
    FILEPATH="$STACK_DIR/$FILENAME"
    echo "Deleting unnecessary file: $FILEPATH"
    rm "$FILEPATH"
  done
done
