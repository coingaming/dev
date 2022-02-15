let
  header = (import ./header.nix);
  protolens = fetchGit {
    url = "https://github.com/coingaming/proto-lens.git";
    rev = "845fc11ad95ca9edd73d5ff0a5994d1a5232e1e9";
  };
  protoc-haskell = header.pkgs.haskell-nix.project {
    src = "${protolens}/proto-lens-protoc";
    compiler-nix-name = "ghc865";
  };
  protoc-haskell-bin = protoc-haskell.hsPkgs.proto-lens-protoc.components.exes.proto-lens-protoc;
in {
  inherit protoc-haskell-bin;
}
