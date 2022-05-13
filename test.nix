let
  p = (import ./nix/project.nix).project {};
  nixPkgs = (import ./nix/project.nix).nixPkgs;
  prjSrc = (import ./nix/project.nix).prjSrc;
  bc = import ./nix/bitcoin-conf.nix;
  ln = import ./nix/lnd-conf.nix;
  electrs = import ./nix/electrs-conf.nix;
  pg = import ./nix/postgres-conf.nix;
  lsp = import ./nix/lsp-conf.nix;
  bitcoindConf = nixPkgs.callPackage bc {
    name="alice";
    dataDir=".";
    port=18444;
    rpcport=18443;
  };
  bitcoindConf2 = nixPkgs.callPackage bc {
    name="bob";
    dataDir=".";
    port=21000;
    rpcport=21001;
  };
  lndLsp = nixPkgs.callPackage ln {
    port = 9736;
    rpcport = 10010;
    restport = 8081;
    dataDir = ".";
    name = "lsp";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
  };
  lndAlice = nixPkgs.callPackage ln {
    port = 9737;
    rpcport = 10011;
    restport = 8082;
    dataDir = ".";
    name = "alice";
    macaroonDir = "${prjSrc}/btc-lsp/test/Macaroon/";
  };
  lndBob = nixPkgs.callPackage ln {
    port = 9738;
    rpcport = 10012;
    restport = 8083;
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
  lspEnv = nixPkgs.callPackage lsp {
    aliceCerts = lndAlice.tlscert;
    lspCerts = lndLsp.tlscert;
    dataDir = ".";
    inherit prjSrc;
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
  btc-lsp-test =  nixPkgs.runCommand "btc-lsp-test" ({
    buildInputs=[nixPkgs.ps];
  }) ''
    set -euo pipefail
    source ${lspEnv.exportEnvFile}
    env
    ${bitcoindConf.up}/bin/up
    ${lndLsp.up}/bin/up
    ${lndAlice.up}/bin/up
    ${lndBob.up}/bin/up
    ${electrsAlice.up}/bin/up
    ${bitcoindConf2.up}/bin/up
    ${bitcoindConf.cli}/bin/bitcoin-cli addnode "127.0.0.1:21000" "add"
    ${postgres.up}/bin/up
    ${lspEnv.setup}/bin/setup
    sleep 10
    ${btcLspTest}/bin/btc-lsp-test 2>&1 | tee $out
  '';
}
