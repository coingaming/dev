let
  header = (import ./header.nix);
  protolens = fetchGit {
    url = "git@github.com:coingaming/proto-lens.git";
    rev = "845fc11ad95ca9edd73d5ff0a5994d1a5232e1e9";
  };
  signable = fetchGit {
    url = "git@github.com:coingaming/signable.git";
    rev = "192beaf4cd951144385f63516370607014a29dd5";
  };
  protoc-haskell = header.pkgs.haskell-nix.project {
    src = "${protolens}/proto-lens-protoc";
    compiler-nix-name = "ghc865";
  };
  protoc-signable = header.pkgs.haskell-nix.project {
    src = "${signable}/haskell/signable-haskell-protoc";
    compiler-nix-name = "ghc865";
  };
  protoc-haskell-bin = protoc-haskell.hsPkgs.proto-lens-protoc.components.exes.proto-lens-protoc;
  protoc-signable-bin = protoc-signable.hsPkgs.signable-haskell-protoc.components.exes.signable-haskell-protoc;
in {
  inherit protoc-haskell-bin protoc-signable-bin;
}
