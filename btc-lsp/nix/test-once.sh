kill -0 `cat ./build/shell/bitcoind/regtest/bitcoind.pid`
kill -0 `cat ./build/shell/lnd-lsp/lnd.pid`
kill -0 `cat ./build/shell/lnd-alice/lnd.pid`
kill -0 `cat ./build/shell/lnd-bob/lnd.pid`
pg_ctl -D ./build/shell/postgres status
./nix/ns-shutdown-test-deps.sh
setsid ./nix/ns-prepare.sh & wait
. ./nix/ns-export-test-envs.sh
./nix/ns-gen-proto.sh || true)
hpack
cabal test -j
