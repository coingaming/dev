#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"

mkdir -p "$BUILD_DIR"

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

sh -c "$THIS_DIR/ns-dhall-lint.sh"
