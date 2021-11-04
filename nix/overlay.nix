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
          fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/965a07a99219ccea1a0b93fa03735cac35fc2575"
          ) {
            inherit vimBackground vimColorScheme;
          };
        haskellPackages = super.haskell.packages.ghc901.extend(
          self': super': {

          }
        );
      }
)]
