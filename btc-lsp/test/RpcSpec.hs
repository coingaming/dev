module RpcSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Rpc.Client as Client
import Data.Aeson (encode, object, (.=))
import qualified Data.ByteString.Lazy as BS
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

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
  focus $ itEnv "Rpc Get Balance" $ do
    let jsonMsg =
          BS.toStrict $
            encode $
              object
                [ "jsonrpc" .= ("2.0" :: Text),
                  "method" .= ("blockchain.scripthash.get_balance" :: Text),
                  "params" .= ["" :: Text],
                  "id" .= (0 :: Int)
                ]
    msgReply <- Client.send jsonMsg
    print msgReply
    liftIO $ msgReply `shouldSatisfy` isRight
