{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Helper
  ( waitTillLastBlockProcessedT,
    waitTillLastBlockProcessed
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.ElectrsRpc as Rpc
import Network.Bitcoin (getBlockCount)

waitTillLastBlockProcessed :: Env m => Integer -> m (Either Failure ())
waitTillLastBlockProcessed = runExceptT . waitTillLastBlockProcessedT

waitTillLastBlockProcessedT :: Env m => Integer -> ExceptT Failure m ()
waitTillLastBlockProcessedT 0 = throwE $ FailureElectrs CannotSyncBlockchain
waitTillLastBlockProcessedT decr = do
  sleep $ MicroSecondsDelay 1000000
  bHeight <- withBtcT getBlockCount id
  bHeader <- withElectrsT Rpc.blockHeader ($ Rpc.BlockHeight (coerce bHeight))
  case bHeader of
    Rpc.BlockHeader "" -> waitTillLastBlockProcessedT (decr -1)
    _ -> return ()
