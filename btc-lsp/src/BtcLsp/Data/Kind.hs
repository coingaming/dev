module BtcLsp.Data.Kind
  ( Direction (..),
    MoneyRelation (..),
    BitcoinLayer (..),
    Owner (..),
    Table (..),
  )
where

import BtcLsp.Import.External

data Direction
  = Outgoing
  | Incoming
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

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
  = UserTable
  | SwapIntoLnTable
  | SwapUtxoTable
  | BlockTable
  | LnChanTable
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic,
      Enum,
      Bounded
    )
