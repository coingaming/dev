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
in
{
  envFile = lspEnv.exportEnvFile;
  startAll = nixPkgs.writeShellScriptBin "start-test-deps" ''
    set -euo pipefail
    source ${lspEnv.exportEnvFile}
    ${bitcoindConf.up}/bin/up
    ${lndLsp.up}/bin/up
    ${lndAlice.up}/bin/up
    ${lndBob.up}/bin/up
    ${electrsAlice.up}/bin/up
    ${bitcoindConf2.up}/bin/up
    ${bitcoindConf.cli}/bin/bitcoin-cli addnode "127.0.0.1:21000" "add"
    ${postgres.up}/bin/up
    ${lspEnv.setup}/bin/setup
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
  inherit bitcoindConf;
}

