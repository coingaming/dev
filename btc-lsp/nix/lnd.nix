{ pkgs } :
let
  callPackage = pkgs.callPackage;
  lndnix = "${pkgs.path}/pkgs/applications/blockchains/lnd.nix";
  version = "0.13.3-beta";
  src = pkgs.fetchFromGitHub {
    owner = "lightningnetwork";
    repo = "lnd";
    rev = "v${version}";
    sha256 = "05ai8nyrc8likq5n7i9klfi9550ki8sqklv8axjvi6ql8v9bzk61";
  };
in (callPackage lndnix {
      buildGoModule = args : pkgs.buildGoModule (args // {
        vendorSha256 = "0xf8395g6hifbqwbgapllx38y0759xp374sja7j1wk8sdj5ngql5";
        inherit src version;
      });
    })

