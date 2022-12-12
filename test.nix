{log ? "."}:
let
  project = import ./nix/project.nix;
  p = project.project {};
  src = project.prjSrc;
  nixPkgs = project.nixPkgs;
  deps = import ./nix/test-deps.nix {
    repoDir = builtins.toString ./.;
    dataDir = ".";
  };
  networkBitcoinTest = p.network-bitcoin.components.tests.network-bitcoin-tests;
  genericPrettyInstancesTest = p.generic-pretty-instances.components.tests.generic-pretty-instances-test;
  btcLspTest = p.btc-lsp.components.tests.btc-lsp-test;
  electrsClientTest = p.electrs-client.components.tests.electrs-client-test;
  stateful-test = nixPkgs.writeShellScriptBin "stateful-test" ''
    set -x
    out=${log}
    mkdir -p $out/logs
    logsdir="$out/logs"
    echo "$logsdir"

    ${genericPrettyInstancesTest}/bin/generic-pretty-instances-test 2>&1 | tee $out/generic-pretty-instances-test.log

    ${deps.bitcoindConf.up}/bin/up
    ${networkBitcoinTest}/bin/network-bitcoin-tests 2>&1 | tee $out/network-bitcoin-test.log
    ${deps.bitcoindConf.down}/bin/down


    ${deps.startAll}/bin/start-test-deps
    source ${deps.envFile}
    set +e
    ${btcLspTest}/bin/btc-lsp-test 2>&1 | tee $out/lsp-test-log.txt
    retCode="$?"
    set -e
    whoami
    pwd
    ls -la $logsdir
    cp ./lnd-alice/stdout.log "$logsdir/lnd-alice.stdout.log"
    cp ./lnd-bob/stdout.log "$logsdir/lnd-bob.stdout.log"
    cp ./lnd-lsp/stdout.log "$logsdir/lnd-lsp.stdout.log"
    ls -la $logsdir
    ${deps.stopAll}/bin/stop-test-deps
    if [ $retCode -ne 0 ]; then
      echo "lsp tests failed"
      exit "$retCode"
    fi

    ${deps.startElectrs}/bin/start-test-electrs
    source ${deps.envFile}
    ${electrsClientTest}/bin/electrs-client-test 2>&1 | tee $out/electrs-test.log
    ${deps.stopElectrs}/bin/stop-test-electrs
  '';
  ormolu-test = nixPkgs.writeShellScriptBin "ormolu-test" ''
    ${nixPkgs.ormolu}/bin/ormolu --mode check $( find ${src} \( \
      -path '${src}/btc-lsp/src/BtcLsp/*' \
      -o -path '${src}/btc-lsp/test/*' \
      -o -path '${src}/btc-lsp/integration/*' \
      -o -path '${src}/generic-pretty-instances/src/*' \
      -o -path '${src}/generic-pretty-instances/test/*' \
      -o -path '${src}/electrs-client/src/*' \
      -o -path '${src}/electrs-client/test/*' \) \
      -name '*.hs' )
  '';
  hlint-test = nixPkgs.writeShellScriptBin "hlint-test" ''
    ${nixPkgs.hlint}/bin/hlint ${src} --ignore-glob=${src}/btc-lsp/src/Proto
  '';
in
  nixPkgs.writeShellScriptBin "all-tests" ''
    ${ormolu-test}/bin/ormolu-test
    ${hlint-test}/bin/hlint-test
    ${stateful-test}/bin/stateful-test
  ''
