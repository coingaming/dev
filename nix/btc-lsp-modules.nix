{pkgs} : [{
  packages.classy-prelude-yesod.components.library.doHaddock = false;
  packages.btc-lsp.components.exes.btc-lsp-exe.dontStrip = false;
  packages.btc-lsp.components.exes.btc-lsp-exe.enableShared = false;
  packages.btc-lsp.components.exes.btc-lsp-integration.dontStrip = false;
  packages.btc-lsp.components.exes.btc-lsp-integration.enableShared = false;
  packages.btc-lsp.components.tests.btc-lsp-test.preCheck = ''
    ./btc-lsp/nix/ns-gen-cfgs.sh
    ./btc-lsp/nix/ns-gen-keys.sh
    source ./btc-lsp/nix/ns-export-test-envs.sh;
    ./btc-lsp/nix/ns-reset-test-data.sh;
    ./btc-lsp/nix/ns-spawn-test-deps.sh;
  '';
  packages.btc-lsp.components.tests.btc-lsp-test.build-tools = [
    pkgs.haskellPackages.hspec-discover
    pkgs.postgresql
    pkgs.openssl
    pkgs.electrs
    pkgs.bitcoind
    pkgs.lnd
  ];
  packages.btc-lsp.components.exes.btc-lsp-integration.build-tools = [
    pkgs.haskellPackages.hspec-discover
    pkgs.postgresql
    pkgs.openssl
    pkgs.bitcoind
    pkgs.lnd
    pkgs.electrs
  ];
  packages.btc-lsp.components.tests.btc-lsp-test.postCheck = ''
    ./btc-lsp/nix/ns-shutdown-test-deps.sh
  '';
}]
