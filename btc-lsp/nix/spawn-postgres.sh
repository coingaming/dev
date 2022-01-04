#!/bin/sh

#INFO: nix postgres don't like long sockets paths

export PGDATA="$PWD/postgres"
export SOCKET_DIRECTORIES=`mktemp -d`
initdb -D $PGDATA --auth=trust --no-locale --encoding=UTF8
echo "unix_socket_directories = '$SOCKET_DIRECTORIES'" >> $PGDATA/postgresql.conf
pg_ctl -D $PGDATA -l $PGDATA/postgres.log start

createuser -s postgres -h "$SOCKET_DIRECTORIES"
createdb -h localhost lsp
createdb -h localhost lsp-test
