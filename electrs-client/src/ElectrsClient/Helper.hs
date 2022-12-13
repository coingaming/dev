module ElectrsClient.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed,
  )
where

import qualified Control.Concurrent.Thread.Delay as Delay (delay)
import qualified Data.ByteString.Lazy as BS
import qualified Data.Digest.Pure.SHA as SHA
  ( bytestringDigest,
    sha256,
  )
import ElectrsClient.Data.Env
import ElectrsClient.Import.External
import ElectrsClient.Rpc as Rpc
import ElectrsClient.Type
import Network.Bitcoin (Client, getBlockCount, getBlockHash)
import qualified Text.Hex as TH

waitTillLastBlockProcessed ::
  ( MonadUnliftIO m
  ) =>
  Client ->
  ElectrsEnv ->
  Natural ->
  m (Either RpcError ())
waitTillLastBlockProcessed c e =
  runExceptT . waitTillLastBlockProcessedT c e

waitTillLastBlockProcessedT ::
  ( MonadUnliftIO m
  ) =>
  Client ->
  ElectrsEnv ->
  Natural ->
  ExceptT RpcError m ()
waitTillLastBlockProcessedT _ _ 0 =
  throwE CannotSyncBlockchain
waitTillLastBlockProcessedT client env decr =
  flip catchE onFailure $ do
    bHeight <- liftIO $ getBlockCount client
    bHash <- liftIO $ getBlockHash client bHeight
    bHeader <- ExceptT $ Rpc.blockHeader env $ BlkHeight $ fromInteger bHeight
    unless
      ( (doubleSha256AndReverse <$> TH.decodeHex (unBlockHeader bHeader))
          == TH.decodeHex (unBlockHeader $ Rpc.BlockHeader bHash)
      )
      sleepAndRetry
  where
    sleepAndRetry = do
      liftIO $ Delay.delay 300
      waitTillLastBlockProcessedT client env $ decr - 1
    onFailure = \case
      --
      -- TODO : identify out of sync failure better
      --
      RpcJsonDecodeError {} -> sleepAndRetry
      e -> throwE e
    doubleSha256AndReverse =
      BS.toStrict
        . BS.reverse
        . SHA.bytestringDigest
        . SHA.sha256
        . SHA.bytestringDigest
        . SHA.sha256
        . BS.fromStrict
