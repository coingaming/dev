{
  profile ? false,
}:
with (import ./project.nix);
let
  exe = (project {}).btc-lsp.components.exes.btc-lsp-integration;
  hspec = nixPkgs.haskellPackages.hspec;
  hspec-discover = nixPkgs.haskellPackages.hspec-discover;
in
  nixPkgs.dockerTools.buildImage {
    name = "ghcr.io/coingaming/btc-lsp-integration";
    contents = [
      exe
    ];
    config = {
      Cmd = [ "${exe}/bin/btc-lsp-integration" ];
    };
  }
