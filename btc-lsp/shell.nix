{
  withHaskellIde ? false,
  withShellHook ? false,
  profile ? false,
}:
with (import ./nix/haskell.nix);
let proto = import ./nix/proto-lens-protoc.nix;
    kompose-src = import ./nix/kompose.nix;
    ideBuildInputs =
      if withHaskellIde
      then [(import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/e73945947a367ed9bae735e276664a3efe6ea80f") {bundle = ["dhall" "haskell"];})]
      else [];
in
(project {

}).shellFor {
  withHoogle = true;
  buildInputs = ideBuildInputs ++ [
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.zlib
    pkgs.protobuf
    pkgs.netcat-gnu
    pkgs.socat
    pkgs.plantuml
    proto.protoc-haskell-bin
    (pkgs.callPackage kompose-src {})
  ];
  tools = {
    cabal = "3.2.0.0";
    hlint = "3.2.7";
    ghcid = "latest";
    haskell-language-server = "latest";
  };
  shellHook =
    if withShellHook
    then ''
      echo "Spawning nix-shell with shellHook"
      rm -rf ./build/shell
      sh ./nix/ns-gen-cfgs.sh
      sh ./nix/ns-gen-keys.sh
      . ./nix/ns-export-test-envs.sh
      trap "./nix/ns-shutdown-test-deps.sh 2> /dev/null" EXIT
    ''
    else ''
      echo "Spawning nix-shell without shellHook"
    '';
}
