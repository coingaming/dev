#!/bin/sh

set -e

CONFIG_PATH="$HOME/.kube/config"
LOCALHOST="127.0.0.1"
DOCKERHOST="kubernetes.docker.internal"

if [ `uname -s` = "Darwin" ]; then
  sed -i ".bak" "s/$LOCALHOST/$DOCKERHOST/" "$CONFIG_PATH"
  echo "Replaced $LOCALHOST with $DOCKERHOST in $CONFIG_PATH"
else
  echo "Skipping edit of $CONFIG_PATH because it's only required for MacOS"
fi
