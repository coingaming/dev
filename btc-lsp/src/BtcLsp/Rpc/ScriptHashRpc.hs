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
import Data.Aeson (decode, encode, withObject, (.:))
import qualified Data.ByteString.Lazy as BS
import Data.Digest.Pure.SHA
import qualified Network.Bitcoin.Wallet as BtcW
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
    Left _ -> pure $ Left (OtherError "Getting ScriptHash error")

getScriptHash :: (Env m) => OnChainAddress a -> m (Either Failure ScriptHash)
getScriptHash addr = runExceptT $ do
  BtcW.AddrInfo _ sp <- withBtcT BtcW.getAddrInfo ($ coerce addr)
  decodeSp sp
  where
    decodeSp :: (Env m) => BtcW.ScrPubKey -> ExceptT Failure m ScriptHash
    decodeSp =
      ExceptT
        . pure
        . second sha256AndReverse
        . maybeToRight (FailureBitcoind RpcHexDecodeError)
        . TH.decodeHex
        . coerce
    sha256AndReverse =
      ScriptHash
        . TH.encodeHex
        . BS.toStrict
        . BS.reverse
        . bytestringDigest
        . sha256
        . BS.fromStrict
