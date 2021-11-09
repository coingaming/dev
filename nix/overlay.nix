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
          fetchTarball "https://github.com/21it/ultimate-haskell-ide/tarball/26b9292cdde4a7977309dbb98291929c7f740d2a"
          ) {
            inherit vimBackground vimColorScheme;
          };
        haskellPackages = super.haskell.packages.ghc865Binary.extend(
          self': super': {

          }
        );
      }
)]
