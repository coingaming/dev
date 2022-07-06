{-# LANGUAGE OverloadedStrings #-}

module ElectrsClient.RpcRequest
  ( RpcRequest (..),
    Method (..),
  )
where

import ElectrsClient.Import.External
import Data.Aeson (ToJSON (toJSON), Value (String))

data RpcRequest a = RpcRequest
  { id :: Integer,
    jsonrpc :: Text,
    method :: Method,
    params :: a
  }
  deriving stock (Generic, Show)

instance ToJSON a => ToJSON (RpcRequest a)

data Method
  = GetBalance
  | Version
  | GetBlockHeader
  deriving stock (Generic, Show)

instance ToJSON Method where
  toJSON GetBalance = String "blockchain.scripthash.get_balance"
  toJSON Version = String "server.version"
  toJSON GetBlockHeader = String "blockchain.block.header"
