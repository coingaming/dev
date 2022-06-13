with (import ./project.nix);
let
  proto = import ./proto-lens-protoc.nix;
  deps = import ./test-deps.nix {dataDir = "./build";};
in
  (project {}).shellFor {
  withHoogle = true;
  buildInputs = [
    nixPkgsLegacy.cabal-install
    nixPkgs.haskellPackages.hpack
    nixPkgs.haskellPackages.fswatcher
    nixPkgs.haskellPackages.cabal-plan
    nixPkgs.haskellPackages.hp2pretty
    nixPkgs.haskellPackages.hspec-discover
    nixPkgs.haskellPackages.implicit-hie
    nixPkgs.zlib
    nixPkgs.protobuf
    nixPkgs.netcat-gnu
    nixPkgs.socat
    proto.protoc-haskell-bin
    deps.startAll
    deps.stopAll
  ];
  tools = {
    hlint = "latest";
    ghcid = "latest";
    haskell-language-server = "latest";
  };
  shellHook = ''
    gen-hie > hie.yaml
  '';
}
