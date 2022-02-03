{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Env
  ( RpcEnv(..)
  )
where

import BtcLsp.Import.External
import Data.Aeson (FromJSON (..), withObject, (.:))

data RpcEnv = RpcEnv
  { rpcEnvPort :: Text,
    rpcEnvHost :: Text
  }
  deriving (Generic)

instance FromJSON RpcEnv where
  parseJSON =
    withObject
      "RpcEnv"
      ( \x ->
          RpcEnv
            <$> x .: "port"
            <*> x .: "host"
      )

