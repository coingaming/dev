{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.RpcRequest
  ( RpcRequest (..),
    Method (..),
  )
where

import BtcLsp.Import
import Data.Aeson (ToJSON (toJSON), Value (String))

data RpcRequest a = RpcRequest
  { id :: Integer,
    jsonrpc :: Text,
    method :: Method,
    params :: a
  }
  deriving (Generic, Show)

instance ToJSON a => ToJSON (RpcRequest a)

data Method
  = GetBalance
  | Version
  deriving (Generic, Show)

instance ToJSON Method where
  toJSON GetBalance = String "blockchain.scripthash.get_balance"
  toJSON Version = String "server.version"
