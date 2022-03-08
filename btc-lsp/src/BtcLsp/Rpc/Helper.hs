{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ElectrsRpc as Rpc
import Network.Bitcoin (getBlockCount, getBlockHash)
import qualified Text.Hex as TH
import Data.Digest.Pure.SHA (bytestringDigest, sha256)
import qualified Data.ByteString.Lazy as BS

waitTillLastBlockProcessed :: Env m => Integer -> m (Either Failure ())
waitTillLastBlockProcessed = runExceptT . waitTillLastBlockProcessedT

waitTillLastBlockProcessedT :: Env m => Integer -> ExceptT Failure m ()
waitTillLastBlockProcessedT 0 = throwE $ FailureElectrs CannotSyncBlockchain
waitTillLastBlockProcessedT decr = do
  sleep $ MicroSecondsDelay 1000000
  bHeight <- withBtcT getBlockCount id
  bHash <- withBtcT getBlockHash ($ bHeight)
  bHeader <- withElectrsT Rpc.blockHeader ($ BlkHeight (coerce bHeight))
  let bh = TH.decodeHex (coerce bHeader)
--  let bh0 = case bh of
--              Just x -> x
--              Nothing -> error "1"
  let bh2 = BS.toStrict . BS.reverse . bytestringDigest . sha256 . bytestringDigest . sha256 . BS.fromStrict <$> bh
  let maybeBhx = TH.decodeHex (coerce $ Rpc.BlockHeader bHash)
--  let bhx0 = case maybeBhx of
--               Just y -> y
--               Nothing -> error "2"
  if bh2 == maybeBhx then
    return ()
  else
    waitTillLastBlockProcessedT (decr -1)
--  case bHeader of
--    Rpc.BlockHeader "" -> waitTillLastBlockProcessedT (decr -1)
--    _ -> return ()

-- TODO Implement blockHash comparison, now it looks like has different formats so doesn't match
--  if bHeader == Rpc.BlockHeader bHash then
--    return ()
--  else
--    waitTillLastBlockProcessedT (decr -1)
