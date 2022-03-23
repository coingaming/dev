let G = ../Global.dhall

let Rtl = ../Service/Rtl.dhall

let Lnd = ../Service/Lnd.dhall

in  ''
    #!/bin/sh

    set -e

    export CONFIG_FROM_ENV="true"
    export RTL_CONFIG_NODES_JSON='[
      {
        "hexMacaroon": "${Lnd.hexMacaroon}",
        "index": 1,
        "lnServerUrl": "${G.unNetworkScheme
                            G.NetworkScheme.Https}://${G.unOwner
                                                         G.Owner.Lnd}:${G.unPort
                                                                          Lnd.restPort}"
      }
    ]'
    export RTL_CONFIG_JSON='{
      "SSO":{
        "logoutRedirectLink": "",
        "rtlCookiePath": "",
        "rtlSSO": 0
      },
      "defaultNodeIndex": 1,
      "multiPass": "${Rtl.dashboardPass}",
      "nodes": [],
      "port": "${G.unPort Rtl.tcpPort}"
    }'

    ''
