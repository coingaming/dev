module ElectrsClient.RpcResponse
  ( RpcResponse (..),
  )
where

import ElectrsClient.Import.External

data RpcResponse a = RpcResponse
  { id :: Integer,
    jsonrpc :: Text,
    result :: a
  }
  deriving stock (Generic, Show)

instance FromJSON a => FromJSON (RpcResponse a)
