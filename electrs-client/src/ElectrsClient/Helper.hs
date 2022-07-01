module ElectrsClient.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed,
  )
where

import ElectrsClient.Import.External
import ElectrsClient.Type
import ElectrsClient.Rpc as Rpc
import ElectrsClient.Data.Env
import qualified Data.ByteString.Lazy as BS
import qualified Data.Digest.Pure.SHA as SHA
  ( bytestringDigest,
    sha256,
  )
import Network.Bitcoin (getBlockCount, getBlockHash, Client)
import qualified Text.Hex as TH
import qualified Control.Concurrent.Thread.Delay as Delay (delay)

waitTillLastBlockProcessed ::
  ( MonadUnliftIO m
  ) =>
  Client ->
  ElectrsEnv ->
  Natural ->
  m (Either RpcError ())
waitTillLastBlockProcessed c e  =
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
waitTillLastBlockProcessedT client env decr = do
  liftIO $ Delay.delay 300
  bHeight <- liftIO $ getBlockCount client
  bHash <- liftIO $ getBlockHash client bHeight
  bHeader <- ExceptT $ Rpc.blockHeader env $ BlkHeight $ fromInteger bHeight
  if (doubleSha256AndReverse <$> TH.decodeHex (coerce bHeader))
    == TH.decodeHex (coerce $ Rpc.BlockHeader bHash)
    then return ()
    else waitTillLastBlockProcessedT client env (decr -1)
  where
    doubleSha256AndReverse =
      BS.toStrict
        . BS.reverse
        . SHA.bytestringDigest
        . SHA.sha256
        . SHA.bytestringDigest
        . SHA.sha256
        . BS.fromStrict
