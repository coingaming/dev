#!/bin/sh

set -m

. nix/export-test-envs.sh

./nix/spawn-postgres.sh
./nix/spawn-bitcoind.sh
./nix/spawn-lnd.sh "$LND_MERCHANT_DIR" "merchant"
./nix/spawn-lnd.sh "$LND_PAYMENTS_DIR" "payments"

echo "spawn-test-deps executed"
