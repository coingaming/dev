{
  vimBackground ? "light",
  vimColorScheme ? "PaperColor"
}:
[(self: super:
    let
      callPackage = self.lib.callPackageWith self.haskellPackages;
      dontCheck = self.haskell.lib.dontCheck;
      doJailbreak = self.haskell.lib.doJailbreak;
    in
      {
        haskell-ide = import (
          fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/488179c2992bce67f1f42297fca5e04febdb52cc"
          ) {
            inherit vimBackground vimColorScheme;
          };
        haskellPackages = super.haskell.packages.ghc901.extend(
          self': super': {

          }
        );
      }
)]
