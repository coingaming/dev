with (import ./project.nix);
let
  proto = import ./proto-lens-protoc.nix;
  deps = import ./test-deps.nix {dataDir = "./build";};
in
  (project {}).shellFor {
  withHoogle = true;
  buildInputs = [
    nixPkgsLegacy.cabal-install
    pkgs.haskell-language-server
    nixPkgs.haskellPackages.hpack
    nixPkgs.haskellPackages.fswatcher
    nixPkgs.haskellPackages.cabal-plan
    nixPkgs.haskellPackages.hp2pretty
    nixPkgs.haskellPackages.hspec-discover
    nixPkgs.haskellPackages.implicit-hie
    nixPkgs.haskellPackages.hie-bios
    nixPkgs.zlib
    nixPkgs.protobuf
    nixPkgs.netcat-gnu
    nixPkgs.socat
    proto.protoc-haskell-bin
    deps.startAll
    deps.stopAll
    deps.cliAlias
    deps.ghcidLspMain
    deps.ghcidLspTest
    deps.ghcidBtcTest
    deps.mine
    nixBitcoin.lndinit
  ];
  tools = {
    hlint = "latest";
    ghcid = "latest";
  };
  shellHook = ''
    trap "${deps.stopAll}/bin/stop-test-deps 2> /dev/null" EXIT
    gen-hie > hie.yaml
    . ${deps.envFile}
    . cli-alias
  '';
}
