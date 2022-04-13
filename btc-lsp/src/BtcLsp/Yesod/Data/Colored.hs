{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Data.Colored where

import BtcLsp.Yesod.Data.BootstrapColor
import BtcLsp.Yesod.Import

class Colored a where
  color :: a -> Maybe BootstrapColor
