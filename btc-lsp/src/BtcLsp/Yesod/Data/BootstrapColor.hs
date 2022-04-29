module BtcLsp.Yesod.Data.BootstrapColor
  ( BootstrapColor (..),
    bsColor2Class,
  )
where

import BtcLsp.Yesod.Import.NoFoundation

data BootstrapColor
  = Success
  | Info
  | Warning
  | Danger
  deriving stock
    ( Show,
      Read,
      Eq
    )

bsColor2Class :: BootstrapColor -> Text
bsColor2Class =
  pack . toLower . show
