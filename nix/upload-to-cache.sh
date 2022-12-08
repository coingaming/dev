set -eu
set -f # disable globbing
export IFS=' '
echo "Signing and uploading paths" $OUT_PATHS
exec nix copy --to 'file:///tmp/nix_ci_cache' $OUT_PATHS
