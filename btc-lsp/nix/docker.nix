{
  profile ? false,
}:
with (import ./haskell.nix);
let
  btc-lsp = (project {

  }).btc-lsp.components.exes.btc-lsp-exe;
in pkgs.dockerTools.buildImage {
  name = "heathmont/btc-lsp";
  contents = [ btc-lsp ];

  config = {
    Cmd = [ "${btc-lsp}/bin/btc-lsp-exe" ];
    ExposedPorts = {
      "80/tcp" = {};
    };
  };
}
