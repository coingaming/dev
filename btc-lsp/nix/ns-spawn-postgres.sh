#!/bin/sh

#INFO: nix postgres don't like long sockets paths

THIS_DIR="$(dirname "$(realpath "$0")")"
SOCKET_DIRECTORIES=`mktemp -d`

. "$THIS_DIR/ns-export-test-envs.sh"

initdb -D $PGDATA --auth=trust --no-locale --encoding=UTF8
echo "unix_socket_directories = '$SOCKET_DIRECTORIES'" >> $PGDATA/postgresql.conf
echo "log_statement = 'all'" >> $PGDATA/postgresql.conf
pg_ctl -D $PGDATA -l $PGDATA/postgres.log start

createuser -s postgres -h "$SOCKET_DIRECTORIES"
createdb -h localhost lsp
createdb -h localhost lsp-test
