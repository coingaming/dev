#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

inline_text() {
  awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $1
}

echo "==> Compacting multiline creds (to work correctly with k8s secrets)"
for OWNER in lnd lsp; do
  BUILD_PATH="$BUILD_DIR/$OWNER"

  for FILE_PATH in "$BUILD_PATH"/tls.*; do
    if [ -f "$FILE_PATH" ]; then
      CONTENT=$(cat "$FILE_PATH" | inline_text)
      FILE_NAME=$(basename -- "$FILE_PATH")
      NEW_FILE_PATH="$BUILD_PATH/inlined-$FILE_NAME"

      echo "Saved into $NEW_FILE_PATH"
      echo -n "$CONTENT" > "$NEW_FILE_PATH"
    fi
  done
done
