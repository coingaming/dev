module ElectrsClient.Type
  ( RpcError (..),
    OnChainAddress (..),
    BlkHeight (..),
  )
where

import ElectrsClient.Import.External

data RpcError
  = RpcNoAddress
  | RpcJsonDecodeError
  | RpcHexDecodeError
  | CannotSyncBlockchain
  | OtherError Text
  deriving stock
    ( Eq,
      Generic,
      Show
    )

newtype OnChainAddress (mrel :: MoneyRelation)
  = OnChainAddress Text
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read
    )
  deriving stock
    ( Generic
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

newtype BlkHeight
  = BlkHeight Word64
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )
  deriving newtype
    ( Num,
      ToJSON
    )
