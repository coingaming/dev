let Postgres = ../Service/Postgres.dhall

in  ''
    #!/bin/sh

    set -e

    export ${Postgres.env.postgresUser}="${Postgres.user}"
    export ${Postgres.env.postgresPass}="${Postgres.pass}"
    export ${Postgres.env.postgresHost}="${Postgres.host}"
    export ${Postgres.env.postgresDb}="${Postgres.database}"
    ''
