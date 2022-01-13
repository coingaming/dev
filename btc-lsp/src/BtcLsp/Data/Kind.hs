module BtcLsp.Data.Kind
  ( TxDirection (..),
  )
where

import BtcLsp.Import.External

data TxDirection
  = Fund
  | Refund
  deriving
    ( Eq,
      Ord,
      Show,
      Generic
    )
