#!/bin/sh

set -e

THIS_DIR="$(dirname "$(realpath "$0")")"
SHELL_DIR="$THIS_DIR/../build/shell"

(
  kill -0 `cat $SHELL_DIR/bitcoind/regtest/bitcoind.pid` && \
  kill -0 `cat $SHELL_DIR/bitcoind2/regtest/bitcoind.pid` && \
  kill -0 `cat $SHELL_DIR/lnd-lsp/lnd.pid` && \
  kill -0 `cat $SHELL_DIR/lnd-alice/lnd.pid` && \
  kill -0 `cat $SHELL_DIR/lnd-bob/lnd.pid` && \
  pg_ctl -D $SHELL_DIR/postgres status && \
  echo "==> Shell services are still running"
) || (
  ($THIS_DIR/ns-shutdown-test-deps.sh || true) && \
  (setsid $THIS_DIR/ns-prepare.sh & wait)
)

. $THIS_DIR/ns-export-test-envs.sh

#($THIS_DIR/ns-gen-proto.sh || true)

hpack
