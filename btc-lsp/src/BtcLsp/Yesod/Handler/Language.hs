{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.Language where

import qualified BtcLsp.Yesod.Data.Language as Lang
import BtcLsp.Yesod.Import

getLanguageR :: Lang.Code -> Handler ()
getLanguageR language = do
  setLanguage $ toPathPiece language
  setUltDestReferer
  redirectUltDest HomeR
