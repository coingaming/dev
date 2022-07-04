with (import ./project.nix);

pkgs.stdenv.mkDerivation {
  name = "seed-shell";
  buildInputs = [nixBitcoin.lndinit];
}
