let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let network = G.BitcoinNetwork.RegTest

let sharedEnv = ../scripts/export-rtl-env.dhall

in  ''
    #!/bin/sh

    set -e

    ${sharedEnv}

    export ${Rtl.env.rtlConfigJson}='${Rtl.mkRtlConfigJson network}'
    ''
