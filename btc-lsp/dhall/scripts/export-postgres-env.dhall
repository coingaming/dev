let Postgres = ../Service/Postgres.dhall

in  ''
    #!/bin/sh

    set -e

    export ${Postgres.env.postgresUser}="${Postgres.user}"
    export ${Postgres.env.postgresPassword}="${Postgres.password}"
    export ${Postgres.env.postgresDatabase}="${Postgres.database}"
    ''
