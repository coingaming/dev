{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module BtcLsp.Rpc.ScriptHashRpc
  ( getBalance,
    version,
    Balance (..),
    ScriptHash (..),
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.Client as Client
import BtcLsp.Rpc.Env
import BtcLsp.Rpc.RpcRequest as Req
import BtcLsp.Rpc.RpcResponse as Resp
import Data.Aeson (decode, encode, object, withObject, (.:), (.=))
import qualified Data.ByteString.Lazy as BS
import Data.Digest.Pure.SHA
import Network.HTTP.Client as HTTPClient hiding (Proxy)
import qualified Text.Hex as TH

newtype ScriptHash = ScriptHash Text
  deriving (Generic)

data Balance = Balance
  { confirmed :: MSat,
    unconfirmed :: MSat
  }
  deriving (Generic, Show)

getBalanceFromSat :: MSat -> MSat -> Balance
getBalanceFromSat c u = Balance (c * 1000) (u * 1000)

instance FromJSON Balance where
  parseJSON = withObject "Balance" $ \v ->
    getBalanceFromSat
      <$> v .: "confirmed"
      <*> v .: "unconfirmed"

instance ToJSON ScriptHash

callRpc :: (Env m, ToJSON req, FromJSON resp) => Method -> req -> ElectrsEnv -> m (Either RpcError resp)
callRpc m r env = do
  let request =
        RpcRequest
          { Req.id = 0,
            Req.jsonrpc = "2.0",
            Req.method = m,
            Req.params = r
          }
  msgReply <- Client.send (lazyEncode request) env
  pure $ join $ second (second result . lazyDecode) msgReply
  where
    lazyDecode :: FromJSON resp => ByteString -> Either RpcError resp
    lazyDecode = maybeToRight RpcJsonDecodeError . decode . BS.fromStrict
    lazyEncode :: ToJSON req => RpcRequest req -> ByteString
    lazyEncode = BS.toStrict . encode

version :: Env m => ElectrsEnv -> () -> m (Either RpcError [Text])
version env () = callRpc Version ["" :: Text, "1.4" :: Text] env

getBalance :: Env m => ElectrsEnv -> Either (OnChainAddress a) ScriptHash -> m (Either RpcError Balance)
getBalance env (Right scriptHash) = callRpc GetBalance [scriptHash] env
getBalance env (Left address) = do
  scrHash <- getScriptHash address
  case scrHash of
    Right sh -> getBalance env (Right sh)
    Left _ -> pure $ Left (OtherError "GettingScript Hash error")

------------
-- TODO Below is the implementation of getaddrinfo rpc for bitcoind that needs to be moved to network.bitcoin package
------------
--
getScriptHash :: (Env m) => OnChainAddress a -> m (Either Text ScriptHash)
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

getAddrScriptPubKey :: (Env m) => OnChainAddress a -> m (Either Text Text)
getAddrScriptPubKey addr = do
  manager <- liftIO $ newManager defaultManagerSettings
  let requestObject =
        object
          [ "jsonrpc" .= ("1.0" :: Text),
            "id" .= ("getaddrinfo" :: Text),
            "method" .= ("getaddressinfo" :: Text),
            "params" .= [addr]
          ]
  env <- getBtcEnv
  baseRequest <-
    liftIO $
      applyBasicAuth
        (encodeUtf8 $ bitcoindEnvUsername env)
        (encodeUtf8 $ bitcoindEnvPassword env)
        <$> parseRequest (unpack (bitcoindEnvHost env))
  let request = baseRequest {HTTPClient.method = "POST", requestBody = RequestBodyLBS $ encode requestObject}
  response <- liftIO $ httpLbs request manager
  let responseJson :: Maybe AddrInfoResponse = decode $ responseBody response
  pure $ case responseJson of
    Nothing -> Left "No scriptPubKey"
    Just s -> Right $ coerce s

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

