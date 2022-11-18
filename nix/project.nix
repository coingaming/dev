let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  prjSrc = pkgs.haskell-nix.haskellLib.cleanGit {
    name = "src-all";
    src = ../.;
  };
in
{
  inherit pkgs prjSrc;
  nixPkgs = header.nixPkgs;
  nixPkgsLegacy = header.nixPkgsLegacy;
  nixBitcoin = header.nixBitcoin;
  expectedTestCoveragePercent="55";
  project = {
    src ? prjSrc,
    extraModules ? []
  }: pkgs.haskell-nix.project {
    inherit src;
    projectFileName = "cabal.project";
    compiler-nix-name = header.compiler-nix-name;
    modules = [{
      packages.generic-pretty-instances.components.tests.generic-pretty-instances-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
      packages.btc-lsp.components.tests.btc-lsp-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
      packages.btc-lsp.components.exes.btc-lsp-integration.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
      packages.electrs-client.components.tests.electrs-client-test.build-tools = [
        pkgs.haskellPackages.hspec-discover
      ];
    }] ++ extraModules;
  };
}
