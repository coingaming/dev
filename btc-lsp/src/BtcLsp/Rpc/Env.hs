{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Env
  ( ElectrsEnv (..),
    BitcoindEnv (..),
  )
where

import BtcLsp.Import.External
import Data.Aeson (withObject, (.:))

data ElectrsEnv = ElectrsEnv
  { electrsEnvPort :: Text,
    electrsEnvHost :: Text
  }
  deriving stock (Generic)

instance FromJSON ElectrsEnv where
  parseJSON =
    withObject
      "ElectrsEnv"
      ( \x ->
          ElectrsEnv
            <$> x .: "port"
            <*> x .: "host"
      )

data BitcoindEnv = BitcoindEnv
  { bitcoindEnvHost :: Text,
    bitcoindEnvUsername :: Text,
    bitcoindEnvPassword :: Text
  }
  deriving stock (Generic)

instance FromJSON BitcoindEnv where
  parseJSON =
    withObject
      "BitcoindEnv"
      ( \x ->
          BitcoindEnv
            <$> x .: "host"
            <*> x .: "username"
            <*> x .: "password"
      )
