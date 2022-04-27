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
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

data BitcoinLayer
  = OnChain
  | Ln
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

data Owner
  = Lsp
  | Usr
  | Chan
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )
