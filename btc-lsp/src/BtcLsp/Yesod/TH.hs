module BtcLsp.Yesod.TH
  ( mkMessageNoFallback,
  )
where

import BtcLsp.Yesod.Import.NoFoundation hiding (forM_)
import Data.Foldable (forM_)
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
  forM_ langs $ mkMessage dt folder
  mkMessage dt folder lang
