let
  header = (import ./header.nix);
  pkgs = header.pkgs;
in
  {
    pkgs = pkgs;
    project = {
      profile ? false,
    }: pkgs.haskell-nix.project {
      projectFileName = "cabal.project";
      src = pkgs.haskell-nix.haskellLib.cleanGit {
        name = "network-bitcoin";
        src = ../.;
      };
      compiler-nix-name = "ghc844";
    };
  }
