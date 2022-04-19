#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"

ghcid --test=":main --fail-fast --color -f failed-examples" --command="$THIS_DIR/ns-lazy-respawn.sh && . $THIS_DIR/ns-export-test-envs.sh && cabal new-repl test:btc-lsp-test --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
