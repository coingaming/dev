{ pkgs } :
let
  callPackage = pkgs.callPackage;
  bitcoinnix = "${pkgs.path}/pkgs/applications/blockchains/bitcoin.nix";
  version = "22.0";
  src = pkgs.fetchurl {
    urls = [
      "https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
      "https://bitcoin.org/bin/bitcoin-core-${version}/bitcoin-${version}.tar.gz"
    ];
    sha256 = "d0e9d089b57048b1555efa7cd5a63a7ed042482045f6f33402b1df425bf9613b";
  };
in (callPackage bitcoinnix {
  withGui = false;
  withWallet = true;
  stdenv = (pkgs.stdenv // {
    mkDerivation = args : pkgs.stdenv.mkDerivation (args // { inherit src version; });
  });
})
