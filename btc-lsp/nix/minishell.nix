let nixpkgs = import ./nixpkgs21.nix;
in
{
  pkgs ? import nixpkgs {

  }
}:
with pkgs;

stdenv.mkDerivation {
  name = "minishell";
  buildInputs = [
    nix
    openssl
    #
    # TODO : replace it with minimal possible dhall setup
    #
    (import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/2229c801ed9833e270b797678fbc5be4f49943a8") {bundle = ["dhall"];})
  ];
  LANG="en_US.UTF-8";
  TERM="xterm-256color";
  NIX_SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";
}

