#!/bin/sh

set -e

docker exec -it \
  `docker ps -f name=yolo_postgres --quiet` \
  psql -U btc-lsp btc-lsp
