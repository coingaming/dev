module RpcSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Rpc.Client as Client
import Data.Aeson (encode, object, (.=))
import qualified Data.ByteString.Lazy as BS
import Data.Digest.Pure.SHA
import Network.Bitcoin
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp
--import qualified Data.ByteString as BSS

--import Haskoin.Address
--import Network.Bitcoin.Mining (generateToAddress)

spec :: Spec
spec = do
  itEnv "Rpc Version" $ do
    let jsonMsg =
          BS.toStrict $
            encode $
              object
                [ "jsonrpc" .= ("2.0" :: Text),
                  "method" .= ("server.version" :: Text),
                  "params" .= ["" :: Text, "1.4" :: Text],
                  "id" .= (0 :: Int)
                ]
    msgReply <- Client.send jsonMsg
    liftIO $ msgReply `shouldSatisfy` isRight
  focus $
    itEnv "Rpc Get Balance" $ do
      client <- liftIO $ getClient "http://127.0.0.1:18443" "developer" "developer"
      address <- liftIO $ getNewAddress client Nothing
      let scriptHash = showDigest $ sha256 $ BS.reverse $ encodeUtf8 address
      bal <- liftIO $ getBalance client
      print bal
      print scriptHash

      let jsonMsg =
            BS.toStrict $
              encode $
                object
                  [ "jsonrpc" .= ("2.0" :: Text),
                    "method" .= ("blockchain.scripthash.get_balance" :: Text),
                    "params" .= [scriptHash],
                    "id" .= (0 :: Int)
                  ]
      msgReply <- Client.send jsonMsg
      print msgReply
      liftIO $ msgReply `shouldSatisfy` isRight
