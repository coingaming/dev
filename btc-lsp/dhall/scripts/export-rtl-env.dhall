let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let Lnd = ../Service/Lnd.dhall

in  ''
    #!/bin/sh

    set -e

    export ${Rtl.env.configFromEnv}="true"
    export ${Rtl.env.rtlConfigNodesJson}='[
      {
        "hexMacaroon": "${Lnd.hexMacaroon}",
        "index": 1,
        "lnServerUrl": "${G.unNetworkScheme
                            G.NetworkScheme.Https}://${G.unOwner
                                                         G.Owner.Lnd}:${G.unPort
                                                                          Lnd.restPort}"
      }
    ]'
    ''
