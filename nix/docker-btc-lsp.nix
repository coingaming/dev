{
  profile ? false,
}:
with (import ./project.nix);
let
  exe = (project {}).btc-lsp.components.exes.btc-lsp-exe;
  static = nixPkgs.stdenv.mkDerivation {
    name = "static";
    src = ./../btc-lsp;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/
      cp -R ./config/ $out/
      cp -R ./static/ $out/
    '';
  };
in
  nixPkgs.dockerTools.buildImage {
    name = "ghcr.io/coingaming/btc-lsp";
    tag = "${exe.version}";
    contents = [
      exe
      static # static might be not needed
    ];
    config = {
      Cmd = [ "${exe}/bin/btc-lsp-exe" ];
      ExposedPorts = { "50051/tcp" = {}; };
    };
  }
