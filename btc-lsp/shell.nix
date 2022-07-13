{
  withHaskellIde ? false,
  withShellHook ? false,
  profile ? false,
}:
with (import ./nix/haskell.nix);
let proto = import ./nix/proto-lens-protoc.nix;
    ideBuildInputs =
      if withHaskellIde
      then [(import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/e0e0d992723cce4b2ecbd8ae4f54c4e4fea38792") {bundle = ["dhall" "haskell"]; vimBackground = "light"; })]
      else [];
in
(project { inherit profile; }).shellFor {
  withHoogle = false;
  buildInputs = [
    nixPkgsLegacy.cabal-install
    pkgs.haskell-language-server
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.haskellPackages.hp2pretty
    pkgs.zlib
    nixPkgs.protobuf
    nixPkgs.netcat-gnu
    nixPkgs.socat
    nixPkgs.plantuml
    proto.protoc-haskell-bin
  ] ++ ideBuildInputs;
  tools = {
    hlint = "latest";
    ghcid = "latest";
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
