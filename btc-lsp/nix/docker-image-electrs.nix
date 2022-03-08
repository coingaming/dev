let
  header = (import ./header.nix);
  pkgs = header.pkgs;
  electrs = pkgs.electrs;
in
  pkgs.dockerTools.buildImage {
    name = "heathmont/electrs";
    contents = [ electrs ];
    config = {
      Cmd = [ "${electrs}/bin/electrs" ];
      ExposedPorts = { "80/tcp" = {}; };
    };
  }
