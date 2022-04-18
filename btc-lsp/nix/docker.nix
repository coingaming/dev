{
  profile ? false,
}:
with (import ./haskell.nix);
let
  btc-lsp = (project {
  }).btc-lsp.components.exes.btc-lsp-exe;
  btc-lsp-static = pkgs.stdenv.mkDerivation {
    name = "btc-lsp-static";
    src = ./..;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/
      cp -R ./config/ $out/
      cp -R ./static/ $out/
    '';
  };
in pkgs.dockerTools.buildImage {
  name = "heathmont/btc-lsp";
  contents = [
    btc-lsp
    btc-lsp-static
  ];
  config = {
    Cmd = [ "${btc-lsp}/bin/btc-lsp-exe" ];
    ExposedPorts = { "50051/tcp" = {}; };
  };
}
