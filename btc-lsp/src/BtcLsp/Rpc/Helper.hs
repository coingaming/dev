{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed,
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ElectrsRpc as Rpc
import qualified Data.ByteString.Lazy as BS
import Data.Digest.Pure.SHA (bytestringDigest, sha256)
import Network.Bitcoin (getBlockCount, getBlockHash)
import qualified Text.Hex as TH

waitTillLastBlockProcessed :: Env m => Integer -> m (Either Failure ())
waitTillLastBlockProcessed = runExceptT . waitTillLastBlockProcessedT

waitTillLastBlockProcessedT :: Env m => Integer -> ExceptT Failure m ()
waitTillLastBlockProcessedT 0 = throwE $ FailureElectrs CannotSyncBlockchain
waitTillLastBlockProcessedT decr = do
  sleep $ MicroSecondsDelay 1000000
  bHeight <- withBtcT getBlockCount id
  bHash <- withBtcT getBlockHash ($ bHeight)
  bHeader <- withElectrsT Rpc.blockHeader ($ BlkHeight (coerce bHeight))
  if (doubleSha256AndReverse <$> TH.decodeHex (coerce bHeader)) == TH.decodeHex (coerce $ Rpc.BlockHeader bHash)
    then return ()
    else waitTillLastBlockProcessedT (decr -1)
  where
    doubleSha256AndReverse =
      BS.toStrict
        . BS.reverse
        . bytestringDigest
        . sha256
        . bytestringDigest
        . sha256
        . BS.fromStrict
