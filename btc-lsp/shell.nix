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
      then [(import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/86769387b5dc55d74f69b4566e46d966b2a9b166") {bundle = ["dhall" "haskell"];})]
      else [];
in
(project { inherit profile; }).shellFor {
  withHoogle = true;
  buildInputs = [
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.haskellPackages.hp2pretty
    pkgs.zlib
    pkgs.protobuf
    pkgs.netcat-gnu
    pkgs.socat
    pkgs.plantuml
    proto.protoc-haskell-bin
    (pkgs.callPackage kompose-src {})
  ] ++ ideBuildInputs;
  tools = {
    cabal = "3.2.0.0";
    hlint = "3.2.7";
    ghcid = "latest";
    haskell-language-server = "1.7.0.0";
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
