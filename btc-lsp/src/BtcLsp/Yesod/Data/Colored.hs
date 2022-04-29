{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Data.Colored where

import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import BtcLsp.Yesod.Data.BootstrapColor
import BtcLsp.Yesod.Import

class Colored a where
  color :: a -> Maybe BootstrapColor

instance Colored SwapIntoLn.UtxoInfo where
  color =
    const Nothing
