module BtcLsp.Yesod.Data.BootstrapColor where

import BtcLsp.Yesod.Import.NoFoundation

data BootstrapColor
  = Success
  | Info
  | Warning
  | Danger
  deriving (Show, Read, Eq)
