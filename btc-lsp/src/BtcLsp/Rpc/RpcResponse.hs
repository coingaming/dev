module BtcLsp.Rpc.RpcResponse
  ( RpcResponse (..),
  )
where

import BtcLsp.Import

data RpcResponse a = RpcResponse
  { id :: Integer,
    jsonrpc :: Text,
    result :: a
  }
  deriving (Generic, Show)

instance FromJSON a => FromJSON (RpcResponse a)
