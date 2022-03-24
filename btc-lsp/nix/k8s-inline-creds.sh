#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
BUILD_DIR="$THIS_DIR/../build"

inline_text() {
  awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' $1
}

for OWNER in lnd rtl lsp; do
  for FILE in $BUILD_DIR/$OWNER/*; do
    if [ -f "$FILE" ]; then
      echo "Inlining content in $FILE"
      CONTENT=$(cat "$FILE" | inline_text)
      echo "$CONTENT" > "$FILE"
    fi
  done
done
