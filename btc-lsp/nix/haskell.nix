let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  nixPkgs = header.nixPkgs;
in
  {
    pkgs = pkgs;
    nixPkgs = nixPkgs;
    project = {
      profile ? false,
    }: pkgs.haskell-nix.project {
      projectFileName = "cabal.project";
      src = pkgs.haskell-nix.haskellLib.cleanGit {
        name = "btc-lsp";
        src = ../.;
      };
      compiler-nix-name = header.compiler-nix-name;
      modules = [{
        enableLibraryProfiling = profile;
        packages.classy-prelude-yesod.components.library.doHaddock = false;
        packages.btc-lsp.components.exes.btc-lsp-exe.dontStrip = false;
        packages.btc-lsp.components.exes.btc-lsp-exe.enableShared = false;
        packages.btc-lsp.components.exes.btc-lsp-integration.dontStrip = false;
        packages.btc-lsp.components.exes.btc-lsp-integration.enableShared = false;
        packages.btc-lsp.components.tests.btc-lsp-test.preCheck = ''
          ./nix/ns-gen-cfgs.sh
          ./nix/ns-gen-keys.sh
          source ./nix/ns-export-test-envs.sh;
          ./nix/ns-reset-test-data.sh;
          ./nix/ns-spawn-test-deps.sh;
        '';
        packages.btc-lsp.components.tests.btc-lsp-test.build-tools = [
          pkgs.haskellPackages.hspec-discover
          nixPkgs.postgresql
          nixPkgs.openssl
          nixPkgs.electrs
          nixPkgs.bitcoin
          nixPkgs.lnd
        ];
        packages.btc-lsp.components.exes.btc-lsp-integration.build-tools = [
          nixPkgs.haskellPackages.hspec-discover
          nixPkgs.postgresql
          nixPkgs.openssl
          nixPkgs.bitcoin
          nixPkgs.electrs
          nixPkgs.lnd
        ];
        packages.btc-lsp.components.tests.btc-lsp-test.postCheck = ''
          ./nix/ns-shutdown-test-deps.sh
        '';
      }];
    };
  }
