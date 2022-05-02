module BtcLsp.Data.Kind
  ( MoneyRelation (..),
    BitcoinLayer (..),
    Owner (..),
    Table (..),
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

data Table
  = SwapIntoLnTable
  | UserTable
  | LnChanTable
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic,
      Enum,
      Bounded
    )
