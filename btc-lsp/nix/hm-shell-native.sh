#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
NIX_WITH_HASKELL_IDE="${NIX_WITH_HASKELL_IDE:-false}"
PROFILE="false"

if [ -z "$*" ]; then
  echo "shell ==> using defaults"
else
  for ARG in "$@"; do
    case $ARG in
      --profile)
        PROFILE="true"
        shift
        ;;
      *)
        echo "shell ==> unrecognized ARG $ARG"
        exit 1
        ;;
    esac
  done
fi

nix-shell \
  "$THIS_DIR/../shell.nix" \
  --arg withHaskellIde "$NIX_WITH_HASKELL_IDE" \
  --arg withShellHook true \
  --arg profile "$PROFILE" \
  --option extra-substituters "https://cache.nixos.org https://hydra.iohk.io https://all-hies.cachix.org" \
  --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= all-hies.cachix.org-1:JjrzAOEUsD9ZMt8fdFbzo3jNAyEWlPAwdVuHw4RD43k="
