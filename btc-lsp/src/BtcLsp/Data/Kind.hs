module BtcLsp.Data.Kind
  ( MoneyRelation (..),
    BitcoinLayer (..),
    Owner (..),
  )
where

import BtcLsp.Import.External

data MoneyRelation
  = Fund
  | Refund
  | Gain
  | Loss
  deriving
    ( Eq,
      Ord,
      Show,
      Generic
    )

data BitcoinLayer
  = OnChain
  | Ln
  deriving
    ( Eq,
      Ord,
      Show,
      Generic
    )

data Owner
  = Lsp
  | Customer
  deriving
    ( Eq,
      Ord,
      Show,
      Generic
    )
