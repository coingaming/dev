let
  p = (import ./nix/project.nix).project {};
  nixPkgs = (import ./nix/project.nix).nixPkgs;
  prjSrc = (import ./nix/project.nix).prjSrc;
  bc = import ./nix/bitcoin-conf.nix;
  ln = import ./nix/lnd-conf.nix;
  electrs = import ./nix/electrs-conf.nix;
  pg = import ./nix/postgres-conf.nix;
  bitcoindConf = nixPkgs.callPackage bc {
    name="alice";
    dataDir=".";
  };
  lndLsp = nixPkgs.callPackage ln {
    port = 9735;
    rpcport = 10009;
    restport = 8080;
    dataDir = ".";
    name = "lsp";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
  };
  lndAlice = nixPkgs.callPackage ln {
    port = 9736;
    rpcport = 10010;
    restport = 8081;
    dataDir = ".";
    name = "alice";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
  };
  lndBob = nixPkgs.callPackage ln {
    port = 9737;
    rpcport = 10011;
    restport = 8082;
    dataDir = ".";
    name = "bob";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
  };
  electrsAlice = nixPkgs.callPackage electrs {
    dataDir = ".";
    name = "alice";
    bitcoinDir = "bitcoind_alice";
  };
  postgres = nixPkgs.callPackage pg {
    dataDir = ".";
    name = "postgres_data";
  };
  networkBitcoinTest = p.network-bitcoin.components.tests.network-bitcoin-tests;
  genericPrettyInstancesTest = p.generic-pretty-instances.components.tests.generic-pretty-instances-test;
  btcLspTest = p.btc-lsp.components.tests.btc-lsp-test;
in {
  network-bitcoin-test = nixPkgs.runCommand "network-bitcoin-test" {
    buildInputs=[nixPkgs.ps];
  } ''
    ${bitcoindConf.up}/bin/up
    ps aux | grep bitcoin
    ${networkBitcoinTest}/bin/network-bitcoin-tests > $out
    ${bitcoindConf.down}/bin/down
  '';
  generic-pretty-instances-test = nixPkgs.runCommand "generic-pretty-instances-test" {} ''
    echo "run generic test"
    ${genericPrettyInstancesTest}/bin/generic-pretty-instances-test > $out
    echo $?
  '';
  btc-lsp-test =  nixPkgs.runCommand "btc-lsp-test" {
    buildInputs=[nixPkgs.ps];
  } ''
    set -euo pipefail
    ${bitcoindConf.up}/bin/up
    ${lndLsp.up}/bin/up
    ${lndAlice.up}/bin/up
    ${lndBob.up}/bin/up
    ${electrsAlice.up}/bin/up
    ${postgres.up}/bin/up

    ps aux | grep electrs
    ${btcLspTest}/bin/btc-lsp-test && true
    pwd
    ls -la
    echo "end"

    ${postgres.down}/bin/down
    ${electrsAlice.down}/bin/down
    ${lndLsp.down}/bin/down
    ${lndAlice.down}/bin/down
    ${lndBob.down}/bin/down
    ${bitcoindConf.down}/bin/down

    echo "end"
    touch $out; exit 1
  '';
}


#
    #${lndAlice.up}/bin/up
    #${lndBob.up}/bin/up
#    echo "Starting tests"
#    ls -la
#    ${nixPkgs.ps}/bin/ps aux | grep lnd
#${btcLspTest}/bin/btc-lsp-test
#    echo "Down in progress"

#${lndLsp.down}/bin/down
#    ${lndAlice.down}/bin/down
#    ${lndBob.down}/bin/down
#    ${bitcoindConf.down}/bin/down
