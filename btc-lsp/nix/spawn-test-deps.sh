#!/bin/sh

set -m

. nix/export-test-envs.sh

./nix/spawn-postgres.sh
./nix/spawn-bitcoind.sh

for OWNER in lsp alice bob; do
  ./nix/spawn-lnd.sh "$OWNER"
done

./nix/spawn-electrs.sh

echo "==> spawn-test-deps executed"
