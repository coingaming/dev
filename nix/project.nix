let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  nixPkgs = header.nixPkgs;
  prjSrc = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "coins-src-all";
    src = ../.;
  };
in
{
  pkgs = pkgs;
  nixPkgs = header.nixPkgs;
  prjSrc = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "coins-src-all";
    src = ../.;
  };
  project = {}: pkgs.haskell-nix.project {
    projectFileName = "cabal.project";
    src = prjSrc;
    compiler-nix-name = header.compiler-nix-name;
    modules = [{
      packages.generic-pretty-instances.components.tests.generic-pretty-instances-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
      packages.btc-lsp.components.tests.btc-lsp-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
    }];
  };
}
