{
  extraBuildInputs ? [],
  withShellHook ? false,
  profile ? false,
}:
with (import ./nix/haskell.nix);
let p = import ./nix/proto-lens-protoc.nix;
in
(project {

}).shellFor {
  withHoogle = true;
  buildInputs = extraBuildInputs ++ [
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.zlib
    pkgs.protobuf
    p.protoc-haskell-bin
    p.protoc-signable-bin
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
