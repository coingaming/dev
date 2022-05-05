{
  profile ? false,
}:
with (import ./haskell.nix);
let
  btc-lsp-integration = (project {}).btc-lsp.components.exes.btc-lsp-integration;
  hspec = nixPkgs.haskellPackages.hspec;
  hspec-discover = nixPkgs.haskellPackages.hspec-discover;
in nixPkgs.dockerTools.buildImage {
  name = "heathmont/btc-lsp-integration";
  contents = [ btc-lsp-integration ];
  config = {
    Cmd = [ "${btc-lsp-integration}/bin/btc-lsp-integration" ];
  };
}
