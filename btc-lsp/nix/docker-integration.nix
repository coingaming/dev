{
  profile ? false,
}:
with (import ./haskell.nix);
let
  btc-lsp-integration = (project {}).btc-lsp.components.exes.btc-lsp-integration;
  hspec = pkgs.haskellPackages.hspec;
  hspec-discover = pkgs.haskellPackages.hspec-discover;
in pkgs.dockerTools.buildImage {
  name = "heathmont/btc-lsp-integration";
  contents = [ btc-lsp-integration hspec hspec-discover ];
  config = {
    Cmd = [ "${btc-lsp-integration}/bin/btc-lsp-integration-exe" ];
    ExposedPorts = { "50051/tcp" = {}; };
  };
}
