#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
ROOT_DIR="$THIS_DIR/.."
GITHUB_RELEASE="$(cat "$ROOT_DIR/VERSION" | tr -d '\n')"

(
  cd "$ROOT_DIR"
  git tag "$GITHUB_RELEASE"
  git push --tags
)

echo "==> Success! Released $GITHUB_RELEASE"
