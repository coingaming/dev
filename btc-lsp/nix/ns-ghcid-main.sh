#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

ghcid --test=":main" --command="$THIS_DIR/ns-lazy-respawn.sh && $THIS_DIR/ns-lazy-init-unlock.sh && ($THIS_DIR/ns-connect-nodes.sh || true) && . $THIS_DIR/ns-export-test-envs.sh && cabal new-repl btc-lsp-exe --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
