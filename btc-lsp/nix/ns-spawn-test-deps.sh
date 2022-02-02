#!/bin/sh

set -m

. nix/ns-export-test-envs.sh

./nix/ns-spawn-postgres.sh
./nix/ns-spawn-bitcoind.sh

for OWNER in lsp alice bob; do
  ./nix/ns-spawn-lnd.sh "$OWNER"
done

./nix/ns-spawn-electrs.sh

echo "==> ns-spawn-test-deps executed"
