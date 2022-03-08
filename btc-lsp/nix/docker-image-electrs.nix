let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  electrs = pkgs.electrs;
  entrypoint = pkgs.writeShellScriptBin "entrypoint" ''
    echo "$USER" && echo "$HOME" && echo "HELLO" && ${electrs}/bin/electrs
  '';
in
  pkgs.dockerTools.buildImage {
    name = "heathmont/electrs";
    contents = [ entrypoint ];
    config = {
      Cmd = [ "${entrypoint}/bin/entrypoint" ];
      ExposedPorts = { "80/tcp" = {}; };
    };
  }
