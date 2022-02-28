{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ElectrsRpc as Rpc
import Network.Bitcoin (getBlockCount, getBlockHash)

waitTillLastBlockProcessed :: Env m => Integer -> m (Either Failure ())
waitTillLastBlockProcessed = runExceptT . waitTillLastBlockProcessedT

waitTillLastBlockProcessedT :: Env m => Integer -> ExceptT Failure m ()
waitTillLastBlockProcessedT 0 = throwE $ FailureElectrs CannotSyncBlockchain
waitTillLastBlockProcessedT decr = do
  sleep $ MicroSecondsDelay 1000000
  bHeight <- withBtcT getBlockCount id
  _ <- withBtcT getBlockHash ($ bHeight)
  bHeader <- withElectrsT Rpc.blockHeader ($ BlkHeight (coerce bHeight))
  case bHeader of
    Rpc.BlockHeader "" -> waitTillLastBlockProcessedT (decr -1)
    _ -> return ()

-- TODO Implement blockHash comparison, now it looks like has different formats so doesn't match
--  if bHeader == Rpc.BlockHeader bHash then
--    return ()
--  else
--    waitTillLastBlockProcessedT (decr -1)
