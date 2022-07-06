{-# LANGUAGE OverloadedStrings #-}

module ElectrsClient.Data.Env
  ( ElectrsEnv (..),
    BitcoindEnv (..),
    Env (..),
    RawConfig (..),
    readRawConfig,
    parseFromJSON,
  )
where

import ElectrsClient.Import.External
import Network.Bitcoin as Btc
import Data.Aeson (withObject, (.:))
import qualified Data.Aeson as A (decode)
import Data.ByteString.Lazy.Char8 as C8L (pack)
import qualified Env as E
   ( Error (..),
     Mod,
     Var,
     header,
     help,
     keep,
     nonempty,
     parse,
     var,
   )

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

data Env = Env
  {
    envElectrs :: ElectrsEnv,
    envBtc :: Btc.Client
  }

data RawConfig = RawConfig
  { rawConfigElectrsEnv :: ElectrsEnv,
    rawConfigBtcEnv :: BitcoindEnv
  }

parseFromJSON :: (FromJSON a) => String -> Either E.Error a
parseFromJSON =
  maybe
    (Left $ E.UnreadError "parseFromJSON failed")
    Right
    . A.decode
    . C8L.pack

readRawConfig :: IO RawConfig
readRawConfig =
  E.parse (E.header "ElectrsClient") $
    RawConfig
      <$> E.var (parseFromJSON <=< E.nonempty) "LSP_ELECTRS_ENV" opts
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_BITCOIND_ENV" opts

opts :: E.Mod E.Var a
opts =
  E.keep <> E.help ""
