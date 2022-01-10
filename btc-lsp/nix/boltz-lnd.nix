{ buildGoModule
, fetchFromGitHub
, lib
, tags ? []
}:

buildGoModule rec {
  pname = "boltz-lnd";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "BoltzExchange";
    repo = "boltz-lnd";
    rev = "v${version}";
    sha256 = "1balxqwcn1klwqrmybda9cvbpwmac4mdlb0b8b5055lw71843pgg";
  };

  vendorSha256 = "1c74nd6yk5agqimdn4jfc9hb0ghh3jw85wpdmqbyp0q6aqdyrhq8";

  subPackages = [ "cmd/boltzcli" "cmd/boltzd" ];

  preBuild = let
    buildVars = {
      RawTags = lib.concatStringsSep "," tags;
      GoVersion = "$(go version | egrep -o 'go[0-9]+[.][^ ]*')";
    };
    buildVarsFlags = lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "-X github.com/BoltzExchange/boltz-lnd/build.${k}=${v}") buildVars);
  in
  lib.optionalString (tags != []) ''
    buildFlagsArray+=("-tags=${lib.concatStringsSep " " tags}")
    buildFlagsArray+=("-ldflags=${buildVarsFlags}")
  '';

  meta = with lib; {
    description = "Lightning Network Submarine Swaps";
    homepage = "https://github.com/BoltzExchange/boltz-lnd";
    license = licenses.mit;
    maintainers = with maintainers; [ cypherpunk2140 prusnak ];
  };
}
