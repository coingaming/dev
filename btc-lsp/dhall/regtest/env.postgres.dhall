let Postgres = ../Service/Postgres.dhall

in  ''
    #!/bin/sh

    set -e

    export POSTGRES_USER=${Postgres.user}
    export POSTGRES_PASS=${Postgres.pass}
    export POSTGRES_HOST=${Postgres.host}
    export POSTGRES_DB=${Postgres.database}

    ''
