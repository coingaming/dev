#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"
KUBERNETES_DIR="$BUILD_DIR/kubernetes"

mkdir -p "$KUBERNETES_DIR"

for f in $BUILD_DIR/docker-compose.yolo.yml; do
  kompose convert -f "$f" \
  --with-kompose-annotation=false \
  -o "$KUBERNETES_DIR";
done

for FILENAME in docker-proxy-deployment.yaml docker-proxy-service.yaml; do
  FILEPATH="$KUBERNETES_DIR/$FILENAME"
  echo "Deleting unnecessary file: $FILEPATH"
  rm "$FILEPATH"
done
