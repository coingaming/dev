#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
BUILD_DIR="$ROOT_DIR/build"

# Switch to regtest|testnet|mainnet to generate network-specific k8s resources
BITCOIN_NETWORK=regtest

KUBERNETES_BUILD_DIR="$ROOT_DIR/build/k8s"
SCRIPTS_BUILD_DIR="$ROOT_DIR/build/scripts"

mkdir -p "$KUBERNETES_BUILD_DIR" "$SCRIPTS_BUILD_DIR"

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

dhall_to_sh() {
  FILE_PATH="$1"
  BUILD_PATH="$2"
  [ -f "$FILE_PATH" ] || (echo "FILE_DOES_NOT_EXIST $FILE_PATH" && exit 1)

  FILE_NAME_DHALL=$(basename -- "$x")
  FILE_NAME="${FILE_NAME_DHALL%.dhall}"
  FILE_NAME_SH="$FILE_NAME.sh"
  RESULT_SH="$BUILD_PATH/$FILE_NAME_SH"

  dhall text \
    --file "$x" \
    --output "$RESULT_SH"

  chmod a+x "$RESULT_SH"
}

for x in $ROOT_DIR/dhall/$BITCOIN_NETWORK/k8s.*.dhall; do
  dhall_to_yaml "$x" "$KUBERNETES_BUILD_DIR"
done

for x in $ROOT_DIR/dhall/scripts/*.dhall; do
  dhall_to_sh "$x" "$SCRIPTS_BUILD_DIR"
done

for x in $ROOT_DIR/dhall/$BITCOIN_NETWORK/export*.dhall; do
  dhall_to_sh "$x" "$SCRIPTS_BUILD_DIR"
done

sh -c "$THIS_DIR/ns-dhall-lint.sh"
