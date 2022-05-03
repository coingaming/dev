let
  nixPkgs = (import ./header.nix).nixPkgs;
in
nixPkgs.stdenv.mkDerivation {
  name = "minishell";
  buildInputs = [
    nixPkgs.nix
    nixPkgs.openssl
    nixPkgs.plantuml
    nixPkgs.dhall
    nixPkgs.dhall-json
  ];
  LANG="en_US.UTF-8";
  TERM="xterm-256color";
  NIX_SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";
}

