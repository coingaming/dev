#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"

. "$ROOT_DIR/nix/k8s-export-env.sh"

KUBERNETES_BUILD_DIR="$ROOT_DIR/build/kubernetes/$BITCOIN_NETWORK"

mkdir -p "$BUILD_DIR" "$KUBERNETES_BUILD_DIR"

dhall_to_yaml() {
  FILE_PATH="$1"
  BUILD_PATH="$2"
  [ -f "$FILE_PATH" ] || (echo "FILE_DOES_NOT_EXIST $FILE_PATH" && exit 1)

  FILE_NAME_DHALL=$(basename -- "$FILE_PATH")
  FILE_NAME_WITHOUT_EXT="${FILE_NAME_DHALL%.dhall}"
  FILE_NAME="${FILE_NAME_WITHOUT_EXT#k8s.}"
  FILE_NAME_YAML="$FILE_NAME.yml"
  RESULT_YAML="$BUILD_PATH/$FILE_NAME_YAML"

  dhall-to-yaml \
    --file "$FILE_PATH" \
    --output "$RESULT_YAML" \
    --generated-comment
}

for x in $ROOT_DIR/dhall/docker-compose.*.dhall; do
  dhall_to_yaml "$x" "$BUILD_DIR"
done

for x in $ROOT_DIR/dhall/$BITCOIN_NETWORK/k8s.*.dhall; do
  dhall_to_yaml "$x" "$KUBERNETES_BUILD_DIR"
done

for x in $ROOT_DIR/dhall/$BITCOIN_NETWORK/env.*.dhall; do

  [ -f "$x" ] || (echo "FILE_DOES_NOT_EXIST $x" && exit 1)

  FILE_NAME_DHALL=$(basename -- "$x")
  FILE_NAME_WITHOUT_EXT="${FILE_NAME_DHALL%.dhall}"
  FILE_NAME="${FILE_NAME_WITHOUT_EXT#env.}"
  FILE_NAME_SH="$FILE_NAME.sh"
  RESULT_SH="$KUBERNETES_BUILD_DIR/$FILE_NAME_SH"

  dhall text \
    --file "$x" \
    --output "$RESULT_SH"

  chmod a+x "$RESULT_SH"
done

sh -c "$THIS_DIR/ns-dhall-lint.sh"
