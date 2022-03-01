{
  withHaskellIde ? false,
  withShellHook ? false,
  profile ? false,
}:
with (import ./nix/haskell.nix);
(project {
}).shellFor {
  withHoogle = true;
  buildInputs = [
    pkgs.haskellPackages.hpack
    pkgs.haskellPackages.fswatcher
    pkgs.haskellPackages.cabal-plan
    pkgs.zlib
    pkgs.protobuf
    pkgs.netcat-gnu
    pkgs.socat
  ];
  tools = {
    cabal = "2.2.0.1";
    hlint = "3.2.7";
    ghcid = "latest";
    haskell-language-server = "latest";
  };
  shellHook =
    if withShellHook
    then ''
      echo "Spawning nix-shell with shellHook"
    ''
    else ''
      echo "Spawning nix-shell without shellHook"
    '';
}


