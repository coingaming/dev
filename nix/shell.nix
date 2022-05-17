with (import ./project.nix);
let
  proto = import ./proto-lens-protoc.nix;
  deps = import ./test-deps.nix {dataDir = "./build";};
in
  (project {}).shellFor {
  withHoogle = true;
  buildInputs = [
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
    cabal = "3.2.0.0";
    hlint = "3.2.7";
    ghcid = "latest";
    haskell-language-server = "1.7.0.0";
  };
  shellHook = ''
    gen-hie > hie.yaml
  '';
}
