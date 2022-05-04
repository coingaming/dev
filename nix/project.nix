let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  nixPkgs = header.nixPkgs;
  btcLspModules = import ./btc-lsp-modules.nix { pkgs = nixPkgs; };
  bc = import ./bitcoin-conf.nix;
  bt = nixPkgs.callPackage bc { name = "alice"; dataDir = "./tmp"; };
in
{
  pkgs = pkgs;
  project = {}: pkgs.haskell-nix.project {
    projectFileName = "cabal.project";
    src = pkgs.haskell-nix.haskellLib.cleanGit {
      name = "coins-src-all";
      src = ../.;
    };
    compiler-nix-name = header.compiler-nix-name;
    modules = btcLspModules ++ [{
      packages.generic-pretty-instances.components.tests.generic-pretty-instances-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
      packages.network-bitcoin.components.tests.network-bitcoin-tests = {
        preCheck = ''
          echo "Precheck..."
          setup
          start
          init
        '';
        build-tools = [
          pkgs.haskellPackages.hspec-discover
          bt
        ];
        postCheck = ''
          pwd
          echo "Postcheck..."
          stop
        '';
      };
    }];
  };
}
