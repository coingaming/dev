{ dataDir }:
let
  project =  (import ./project.nix);
  nixPkgs = project.nixPkgs;
  prjSrc = project.prjSrc;
  bc = import ./bitcoin-conf.nix;
  ln = import ./lnd-conf.nix;
  electrs = import ./electrs-conf.nix;
  pg = import ./postgres-conf.nix;
  lsp = import ./lsp-conf.nix;
  bitcoindConf = nixPkgs.callPackage bc {
    name = "alice";
    port = 18444;
    rpcport = 18443;
    inherit dataDir;
  };
  bitcoindConf2 = nixPkgs.callPackage bc {
    name = "bob";
    port = 21000;
    rpcport = 21001;
    inherit dataDir;
  };
  lndLsp = nixPkgs.callPackage ln {
    port = 9736;
    rpcport = 10010;
    restport = 8081;
    name = "lsp";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
    inherit dataDir;
  };
  lndAlice = nixPkgs.callPackage ln {
    port = 9737;
    rpcport = 10011;
    restport = 8082;
    name = "alice";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
    inherit dataDir;
  };
  lndBob = nixPkgs.callPackage ln {
    port = 9738;
    rpcport = 10012;
    restport = 8083;
    name = "bob";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
    inherit dataDir;
  };
  electrsAlice = nixPkgs.callPackage electrs {
    name = "alice";
    bitcoinDir = bitcoindConf.bitcoinDir;
    inherit dataDir;
  };
  postgres = nixPkgs.callPackage pg {
    name = "postgres_data";
    inherit dataDir;
  };
  lspEnv = nixPkgs.callPackage lsp {
    aliceCerts = lndAlice.tlscert;
    lspCerts = lndLsp.tlscert;
    inherit dataDir prjSrc;
  };
  startAll = nixPkgs.writeShellScriptBin "start-test-deps" ''
    set -euo pipefail
    ${bitcoindConf.up}/bin/up
    ${lndLsp.up}/bin/up
    ${lndAlice.up}/bin/up
    ${lndBob.up}/bin/up
    ${electrsAlice.up}/bin/up
    ${bitcoindConf2.up}/bin/up
    echo "test-deps ==> connecting bitcoin nodes..."
    ${bitcoindConf.cli}/bin/bitcoin-cli addnode "127.0.0.1:21000" "add"
    echo "test-deps ==> spawning postgres..."
    ${postgres.up}/bin/up
    echo "test-deps ==> lsp setup..."
    ${lspEnv.setup}/bin/setup
    echo "test-deps ==> done"
  '';
  envFile = lspEnv.exportEnvFile;
in
{
  cliAlias = nixPkgs.writeShellScriptBin "cli-alias" ''
    alias bitcoin-cli="${bitcoindConf.cli}/bin/bitcoin-cli"
    alias bitcoin-cli-2="${bitcoindConf2.cli}/bin/bitcoin-cli"
    alias lncli-lsp="${lndLsp.cli}/bin/lncli"
    alias lncli-alice="${lndAlice.cli}/bin/lncli"
    alias lncli-bob="${lndBob.cli}/bin/lncli"
  '';
  stopAll = nixPkgs.writeShellScriptBin "stop-test-deps" ''
    ${bitcoindConf.down}/bin/down
    ${lndLsp.down}/bin/down
    ${lndAlice.down}/bin/down
    ${lndBob.down}/bin/down
    ${electrsAlice.down}/bin/down
    ${bitcoindConf2.down}/bin/down
    ${postgres.down}/bin/down
  '';
  startElectrs = nixPkgs.writeShellScriptBin "start-test-electrs" ''
    set -euo pipefail
    ${bitcoindConf.up}/bin/up
    ${electrsAlice.up}/bin/up
  '';
  stopElectrs = nixPkgs.writeShellScriptBin "stop-test-electrs" ''
    ${bitcoindConf.down}/bin/down
    ${electrsAlice.down}/bin/down
  '';
  ghcidLspMain = nixPkgs.writeShellScriptBin "ghcid-lsp-main" ''
    ghcid --test=":main" --command="(setsid ${startAll}/bin/start-test-deps & wait) && . ${envFile} && cabal new-repl btc-lsp-exe --disable-optimization --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
  '';
  ghcidLspTest = nixPkgs.writeShellScriptBin "ghcid-lsp-test" ''
    ghcid --test=":main --fail-fast --color -f failed-examples" --command="(setsid ${startAll}/bin/start-test-deps & wait) && . ${envFile} && cabal new-repl test:btc-lsp-test --disable-optimization --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
  '';
  mine = nixPkgs.writeShellScriptBin "mine" ''
    set -e

    echo "==> started mining blocks"

    CURRENT_BLOCK=0
    if [ -z "$1" ]; then
      ASKED_BLOCKS="6"
    else
      ASKED_BLOCKS="$1"
    fi

    if [ $ASKED_BLOCKS -lt 10 ]; then
      BLOCKS2MINE=1
    else
      BLOCKS2MINE=$ASKED_BLOCKS
    fi

    while [ $CURRENT_BLOCK -lt $ASKED_BLOCKS ]; do
      for LNCLI in "${lndLsp.cli}/bin/lncli" "${lndAlice.cli}/bin/lncli" "${lndBob.cli}/bin/lncli"; do

        CURRENT_BLOCK=$(( CURRENT_BLOCK + BLOCKS2MINE ))
        LND_ADDRESS=`$LNCLI newaddress p2wkh | ${nixPkgs.jq}/bin/jq -r '.address' | tr -d '\r\n'`
        echo "$LNCLI ==> got LND_ADDRESS $LND_ADDRESS"
        ${bitcoindConf.cli}/bin/bitcoin-cli generatetoaddress $BLOCKS2MINE $LND_ADDRESS 1>/dev/null
        echo "$LNCLI ==> mined $CURRENT_BLOCK blocks"

        if [ $ASKED_BLOCKS -lt 10 ] && [ $CURRENT_BLOCK -ge $ASKED_BLOCKS ]; then
          break
        fi

      done
    done

    echo "==> mined enough blocks"
  '';
  inherit envFile startAll bitcoindConf;
}

