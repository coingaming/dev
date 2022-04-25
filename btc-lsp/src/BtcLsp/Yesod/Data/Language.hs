{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Yesod.Data.Language where

import BtcLsp.Import.External
import qualified Data.Text as T
import Database.Persist.TH
import qualified Universum

data Code
  = En
  | Ru
  deriving stock
    ( Show,
      Read,
      Eq,
      Enum,
      Bounded
    )

derivePersistField "Code"

codeList :: [Code]
codeList =
  [minBound .. maxBound]

instance PathPiece Code where
  fromPathPiece :: Text -> Maybe Code
  fromPathPiece =
    readMaybe
      . T.unpack
      . T.toTitle
  toPathPiece :: Code -> Text
  toPathPiece =
    T.toLower
      . T.pack
      . Universum.show
