with (import ./project.nix);
let proto = import ./proto-lens-protoc.nix;
in
{}:
  (project {}).shellFor {
  withHoogle = true;
  buildInputs = [
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.haskellPackages.hp2pretty
    pkgs.haskellPackages.hspec-discover
    pkgs.zlib
    pkgs.protobuf
    pkgs.netcat-gnu
    pkgs.socat
    # pkgs.plantuml
    proto.protoc-haskell-bin
  ];
  tools = {
    cabal = "3.2.0.0";
    hlint = "3.2.7";
    ghcid = "latest";
    haskell-language-server = "1.6.1.0";
  };
  shellHook = '''';
  }
