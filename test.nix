let
  project = import ./nix/project.nix;
  p = project.project {};
  nixPkgs = project.nixPkgs;
  deps = import ./nix/test-deps.nix {dataDir = ".";};
  networkBitcoinTest = p.network-bitcoin.components.tests.network-bitcoin-tests;
  genericPrettyInstancesTest = p.generic-pretty-instances.components.tests.generic-pretty-instances-test;
  btcLspTest = p.btc-lsp.components.tests.btc-lsp-test;
  electrsClientTest = p.electrs-client.components.tests.electrs-client-test;
in {
  generic-pretty-instances-test = nixPkgs.runCommand "generic-pretty-instances-test" {} ''
    ${genericPrettyInstancesTest}/bin/generic-pretty-instances-test 2>&1 | tee $out
  '';
  stateful-test = nixPkgs.runCommand "stateful-test" ({
    buildInputs=[nixPkgs.ps];
  }) ''
    ${deps.bitcoindConf.up}/bin/up
    ${networkBitcoinTest}/bin/network-bitcoin-tests 2>&1 | tee $out
    ${deps.bitcoindConf.down}/bin/down

    ${deps.startAll}/bin/start-test-deps
    source ${deps.envFile}
    ${btcLspTest}/bin/btc-lsp-test 2>&1 | tee $out
  '';
  electrs-client-test =  nixPkgs.runCommand "electrs-client-test" ({
    buildInputs=[nixPkgs.ps];
  }) ''
    ${deps.startElectrs}/bin/start-test-electrs
    source ${deps.envFile}
    ${electrsClientTest}/bin/electrs-client-test 2>&1 | tee $out
  '';
}
