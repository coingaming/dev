{ pkgs }: [{
  packages.network-bitcoin.components.tests.network-bitcoin-tests = {
    preCheck = ''
      ./btc-lsp/nix/ns-gen-cfgs.sh
      ./btc-lsp/nix/ns-gen-keys.sh
      source ./btc-lsp/nix/ns-export-test-envs.sh;
      ./btc-lsp/nix/ns-reset-test-data.sh;
      ./btc-lsp/nix/ns-spawn-test-deps.sh;
    '';
    build-tools = [
      pkgs.haskellPackages.hspec-discover
      pkgs.bitcoind
    ];
    postCheck = ''
      ./btc-lsp/nix/ns-shutdown-test-deps.sh
    '';
  };
}]
