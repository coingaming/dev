set -eu
set -f # disable globbing
export IFS=' '
echo $PATH
pwd
echo "Signing and uploading paths" $OUT_PATHS
/nix/var/nix/profiles/default/bin/nix copy --to 'file:///tmp/nix_ci_cache' $OUT_PATHS
/nix/var/nix/profiles/default/bin/nix copy --to 'ssh://cache_coinix' $OUT_PATHS
