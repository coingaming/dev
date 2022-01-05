{
  withHaskellIde ? false,
  withShellHook ? false,
  profile ? false,
}:
with (import ./nix/haskell.nix);
let proto = import ./nix/proto-lens-protoc.nix;
    ideBuildInputs =
      if withHaskellIde
      then [(import (fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/a625bc12de236824c337a2df3f626b2c662434ca") {bundle = "haskell";})]
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
    proto.protoc-haskell-bin
    proto.protoc-signable-bin
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
      . ./nix/export-test-envs.sh
      trap "./nix/shutdown-test-deps.sh 2> /dev/null" EXIT
    ''
    else ''
      echo "Spawning nix-shell without shellHook"
    '';
}
