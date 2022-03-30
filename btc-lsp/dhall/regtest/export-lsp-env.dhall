let G = ../Global.dhall

let Lsp = ../Service/Lsp.dhall

let network = G.BitcoinNetwork.RegTest

let sharedEnv = ../scripts/export-lsp-env.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Lsp.env.lspLibpqConnStr}=${Postgres.mkConnStr network}
    export ${Lsp.env.lspLndP2pHost}="${Lnd.mkHost network}"
    export ${Lsp.env.lspLndEnv}='${Lsp.mkLndEnv network}'
    export ${Lsp.env.lspBitcoindEnv}='${Lsp.mkBitcoindEnv network}'
    ''
