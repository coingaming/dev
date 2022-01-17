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
    (import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/f5aaaddd0a8efcde271cd497c86e300da608c4a8") {bundle = ["dhall"];})
  ];
  LANG="en_US.UTF-8";
  TERM="xterm-256color";
  NIX_SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt";
  GIT_SSL_CAINFO="${cacert}/etc/ssl/certs/ca-bundle.crt";
}

