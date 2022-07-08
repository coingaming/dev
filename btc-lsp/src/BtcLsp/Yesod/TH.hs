module BtcLsp.Yesod.TH
  ( mkMessageNoFallback,
  )
where

import BtcLsp.Yesod.Import.NoFoundation
import Data.List.NonEmpty
import Language.Haskell.TH.Syntax

mkMessageNoFallback ::
  -- | base name to use for translation type
  String ->
  -- | subdirectory which contains the translation files
  FilePath ->
  -- | default translation language is first
  NonEmpty Lang ->
  Q [Dec]
mkMessageNoFallback dt folder (lang :| langs) = do
  void $ mapM (mkMessage dt folder) langs
  mkMessage dt folder lang
