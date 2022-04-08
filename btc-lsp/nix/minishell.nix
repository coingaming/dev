let nixpkgs = import ./nixpkgs21.nix;
in
{
  kompose-src ? import ./kompose.nix,
  pkgs ? import nixpkgs {

  }
}:
with pkgs;

stdenv.mkDerivation {
  name = "minishell";
  buildInputs = [
    nix
    openssl
    plantuml
    (pkgs.callPackage kompose-src {})
    #
    # TODO : replace it with minimal possible dhall setup
    #
    (import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/e73945947a367ed9bae735e276664a3efe6ea80f") {bundle = ["dhall"];})
  ];
  LANG="en_US.UTF-8";
  TERM="xterm-256color";
  NIX_SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";
}

