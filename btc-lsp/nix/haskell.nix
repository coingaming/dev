let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  lnd = import ./lnd.nix { inherit pkgs; };
in
  {
    pkgs = pkgs;
    project = {
      profile ? false,
    }: pkgs.haskell-nix.project {
      projectFileName = "cabal.project";
      src = pkgs.haskell-nix.haskellLib.cleanGit {
        name = "btc-lsp";
        src = ../.;
      };
      compiler-nix-name = "ghc865";
      modules = [{
        packages.btc-lsp.components.exes.btc-lsp-exe.dontStrip = false;
        packages.btc-lsp.components.exes.btc-lsp-exe.enableShared = false;
        packages.btc-lsp.components.tests.btc-lsp-test.preCheck = ''
          ./nix/ns-gen-cfgs.sh
          ./nix/ns-gen-keys.sh
          source ./nix/ns-export-test-envs.sh;
          ./nix/ns-reset-test-data.sh;
          ./nix/ns-spawn-test-deps.sh;
        '';
        packages.btc-lsp.components.tests.btc-lsp-test.build-tools = [
          pkgs.haskellPackages.hspec-discover
          pkgs.postgresql
          pkgs.openssl
          pkgs.bitcoin
          pkgs.electrs
          lnd
        ];
        packages.btc-lsp.components.tests.btc-lsp-test.postCheck = ''
          ./nix/ns-shutdown-test-deps.sh
        '';
      }];
    };
  }
