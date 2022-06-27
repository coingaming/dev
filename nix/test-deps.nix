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
    ${bitcoindConf.cli}/bin/bitcoin-cli addnode "127.0.0.1:21000" "add"
    ${postgres.up}/bin/up
    ${lspEnv.setup}/bin/setup
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
  ghcidLspMain = nixPkgs.writeShellScriptBin "ghcid-lsp-main" ''
    ghcid --test=":main" --command="(${startAll}/bin/start-test-deps || true) && . ${envFile} && cabal new-repl btc-lsp-exe --disable-optimization --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
  '';
  ghcidLspTest = nixPkgs.writeShellScriptBin "ghcid-lsp-test" ''
    ghcid --test=":main --fail-fast --color -f failed-examples" --command="(${startAll}/bin/start-test-deps || true) && . ${envFile} && cabal new-repl test:btc-lsp-test --disable-optimization --repl-options=-fobject-code --repl-options=-fno-break-on-exception --repl-options=-fno-break-on-error --repl-options=-v1 --repl-options=-ferror-spans --repl-options=-j -fghcid"
  '';
  inherit envFile startAll bitcoindConf;
}

