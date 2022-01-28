#!/bin/sh

set -m

. nix/export-test-envs.sh

./nix/spawn-postgres.sh
./nix/spawn-bitcoind.sh
./nix/spawn-lnd.sh "$LND_LSP_DIR" "lsp"
./nix/spawn-lnd.sh "$LND_ALICE_DIR" "alice"
./nix/spawn-electrs.sh

echo "spawn-test-deps executed"
