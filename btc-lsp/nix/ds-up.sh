#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"
VOLUME_DIR="$THIS_DIR/../build/volume"

echo "==> creating volumes"
mkdir -p "$VOLUME_DIR/lnd-lsp"

echo "==> swarm file verification"
docker-compose \
  -f "$THIS_DIR/../build/docker-compose.yolo.yml" \
  config 1>/dev/null

echo "==> swarm file deploy"
docker stack deploy \
  --with-registry-auth \
  -c "$THIS_DIR/../build/docker-compose.yolo.yml" yolo
