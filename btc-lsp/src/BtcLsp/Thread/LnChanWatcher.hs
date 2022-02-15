module BtcLsp.Thread.LnChanWatcher
  (watchChannelEvents, forkThread)
where

import BtcLsp.Import hiding (takeMVar, putMVar, newEmptyMVar)
import UnliftIO.Concurrent (ThreadId, forkFinally, putMVar)
import BtcLsp.Import (newEmptyMVar)
import qualified LndClient.RPC.Silent as Lnd
import BtcLsp.Storage.Model.LnChan (persistChannelUpdates)
import LndClient

forkThread :: MonadUnliftIO m => m () -> m (ThreadId, MVar ())
forkThread proc = do
    handle <- newEmptyMVar
    tid <- forkFinally proc (\_ -> putMVar handle ())
    return (tid, handle)

watchChannelEvents :: (Storage m, KatipContext m) => LndEnv -> m (ThreadId, MVar ())
watchChannelEvents lnd = forkThread $ withRunInIO act
    where
      act run = do
        _ <- Lnd.subscribeChannelEvents (run . persistChannelUpdates) lnd
        pure ()


