{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BtcLsp.Rpc.ScriptHashRpc
  ( getBalance,
    version,
    Balance (..),
    Address (..),
    ScriptHash (..),
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.Client as Client
import BtcLsp.Rpc.RpcRequest as Req
import BtcLsp.Rpc.RpcResponse as Resp
import Data.Aeson (decode, encode, object, withObject, (.:), (.=))
import qualified Data.ByteString.Lazy as BS
import Data.Digest.Pure.SHA
import Network.HTTP.Client as HTTPClient hiding (Proxy)
import qualified Text.Hex as TH

newtype Address = Address Text
  deriving (Generic)

newtype ScriptHash = ScriptHash Text
  deriving (Generic)

data Balance = Balance
  { confirmed :: MSat,
    unconfirmed :: MSat
  }
  deriving (Generic, Show)

instance FromJSON Balance

instance ToJSON Address

instance ToJSON ScriptHash

callRpc :: (Env m, ToJSON req, FromJSON resp) => Method -> req -> m (Either RpcError resp)
callRpc m r = do
  let request =
        RpcRequest
          { Req.id = 0,
            Req.jsonrpc = "2.0",
            Req.method = m,
            Req.params = r
          }
  msgReply <- Client.send $ lazyEncode request
  pure $ join $ second (second result . lazyDecode) msgReply
  where
    lazyDecode :: FromJSON resp => ByteString -> Either RpcError resp
    lazyDecode = maybeToRight RpcJsonDecodeError . decode . BS.fromStrict
    lazyEncode :: ToJSON req => RpcRequest req -> ByteString
    lazyEncode = BS.toStrict . encode

version :: Env m => m (Either RpcError [Text])
version = callRpc Version ["" :: Text, "1.4" :: Text]

getBalance :: Env m => Either Address ScriptHash -> m (Either RpcError Balance)
getBalance (Right scriptHash) = callRpc GetBalance [scriptHash]
getBalance (Left address) = do
  scrHash <- getScriptHash address
  case scrHash of
    Right sh -> getBalance $ Right sh
    Left _ -> pure $ Left (OtherError "GettingScript Hash error")

------------
-- TODO Below is implementation of getaddrinfo rpc for bitcoind that needs to be moved to network.bitcoin package
------------
--
getScriptHash :: (Env m) => Address -> m (Either Text ScriptHash)
getScriptHash addr = do
  scrPubKey <- getAddrScriptPubKey addr
  case scrPubKey of
    Left e -> pure $ Left e
    Right sp -> do
      case TH.decodeHex sp of
        Nothing -> pure $ Left "Hex decode error"
        Just pubKey -> do
          let sha256pubKey = bytestringDigest $ sha256 $ BS.fromStrict pubKey
          let sha256reversedPubKey = BS.reverse sha256pubKey
          pure $ Right $ ScriptHash $ TH.encodeHex $ BS.toStrict sha256reversedPubKey

getAddrScriptPubKey :: (Env m) => Address -> m (Either Text Text)
getAddrScriptPubKey addr = do
  manager <- liftIO $ newManager defaultManagerSettings
  let requestObject =
        object
          [ "jsonrpc" .= ("1.0" :: Text),
            "id" .= ("getaddrinfo" :: Text),
            "method" .= ("getaddressinfo" :: Text),
            "params" .= [addr]
          ]
  env <- getBitcoindEnv
  baseRequest <- liftIO $ applyBasicAuth (username env) (password env) <$> parseRequest (hostname env)
  let request = baseRequest {HTTPClient.method = "POST", requestBody = RequestBodyLBS $ encode requestObject}
  response <- liftIO $ httpLbs request manager
  let responseJson :: Maybe AddrInfoResponse = decode $ responseBody response
  pure $ case responseJson of
    Nothing -> Left "No scriptPubKey"
    Just s -> Right $ coerce (coerce s :: AddrInfo)

newtype AddrInfoResponse = AddrInfoResponse AddrInfo

newtype AddrInfo = AddrInfo Text

instance FromJSON AddrInfoResponse where
  parseJSON = withObject "AddrInfoResponse" $ \v ->
    AddrInfoResponse
      <$> v .: "result"

instance FromJSON AddrInfo where
  parseJSON = withObject "AddrInfo" $ \v ->
    AddrInfo
      <$> v .: "scriptPubKey"

data BitcoindEnv = BitcoindEnv
  { hostname :: String,
    username :: ByteString,
    password :: ByteString
  }

getBitcoindEnv :: MonadUnliftIO m => m BitcoindEnv
getBitcoindEnv =
  pure $
    BitcoindEnv
      { hostname = "http://127.0.0.1:18443",
        username = "developer",
        password = "developer"
      }
