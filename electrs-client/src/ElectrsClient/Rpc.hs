{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module ElectrsClient.Rpc
  ( getBalance,
    version,
    blockHeader,
    Balance (..),
    ScriptHash (..),
    BlockHeader (..),
  )
where

import Data.Aeson (decode, encode, withObject, (.:))
import qualified Data.ByteString.Lazy as BS
import qualified Data.Digest.Pure.SHA as SHA
import ElectrsClient.Client as Client
import ElectrsClient.Data.Env
import ElectrsClient.Import.External
import ElectrsClient.RpcRequest as Req
import ElectrsClient.RpcResponse as Resp
import ElectrsClient.Type
import qualified Network.Bitcoin.Wallet as BtcW
import qualified Text.Hex as TH

newtype ScriptHash = ScriptHash Text
  deriving stock (Generic)

newtype BlockHeader = BlockHeader Text
  deriving newtype (Eq)
  deriving stock (Generic)

instance Out BlockHeader

newtype MSat = MSat Word64
  deriving newtype
    ( Eq,
      Num,
      Ord,
      FromJSON,
      Show,
      Read
    )
  deriving stock
    ( Generic
    )

instance Out MSat

data Balance = Balance
  { confirmed :: MSat,
    unconfirmed :: MSat
  }
  deriving stock (Generic, Show)

getBalanceFromSat :: MSat -> MSat -> Balance
getBalanceFromSat c u = Balance (c * 1000) (u * 1000)

instance FromJSON Balance where
  parseJSON = withObject "Balance" $ \v ->
    getBalanceFromSat
      <$> v .: "confirmed"
      <*> v .: "unconfirmed"

instance ToJSON ScriptHash

instance FromJSON BlockHeader

instance Out Balance

callRpc :: (MonadUnliftIO m, ToJSON req, FromJSON resp) => Method -> req -> ElectrsEnv -> m (Either RpcError resp)
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

version :: MonadUnliftIO m => ElectrsEnv -> () -> m (Either RpcError [Text])
version env () = callRpc Version ["" :: Text, "1.4" :: Text] env

getBalance :: MonadUnliftIO m => ElectrsEnv -> BitcoindEnv -> Either (OnChainAddress a) ScriptHash -> m (Either RpcError Balance)
getBalance env _ (Right scriptHash) = callRpc GetBalance [scriptHash] env
getBalance env bEnv (Left address) = do
  scrHash <- getScriptHash bEnv address
  case scrHash of
    Right sh -> getBalance env bEnv (Right sh)
    Left _ -> pure $ Left (OtherError "Getting ScriptHash error")

blockHeader :: MonadUnliftIO m => ElectrsEnv -> BlkHeight -> m (Either RpcError BlockHeader)
blockHeader env bh = callRpc GetBlockHeader [bh] env

getScriptHash :: (MonadUnliftIO m) => BitcoindEnv -> OnChainAddress a -> m (Either RpcError ScriptHash)
getScriptHash bEnv addr = runExceptT $ do
  btcClient <-
    liftIO $
      BtcW.getClient
        (unpack $ bitcoindEnvHost bEnv)
        (encodeUtf8 $ bitcoindEnvUsername bEnv)
        (encodeUtf8 $ bitcoindEnvPassword bEnv)

  BtcW.AddrInfo _ sp _ _ <- liftIO $ BtcW.getAddrInfo btcClient (coerce addr)
  decodeSp sp
  where
    decodeSp :: (MonadUnliftIO m) => BtcW.ScrPubKey -> ExceptT RpcError m ScriptHash
    decodeSp =
      ExceptT
        . pure
        . second sha256AndReverse
        . maybeToRight RpcHexDecodeError
        . TH.decodeHex
        . coerce
    sha256AndReverse =
      ScriptHash
        . TH.encodeHex
        . BS.toStrict
        . BS.reverse
        . SHA.bytestringDigest
        . SHA.sha256
        . BS.fromStrict
