module BtcLsp.Thread.SwapIntoLn
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn

apply :: (Env m) => m ()
apply = do
  swaps <- SwapIntoLn.getFundedSwaps
  tasks <- mapM (spawnLink . SwapIntoLn.openChannel) swaps
  mapM_ (liftIO . wait) tasks
  sleep $ MicroSecondsDelay 500000
  apply
