module BtcLsp.Thread.LnChanWatcher
  (watchChannelEvents, forkThread, apply, applyListChannelWatcher)
where

import BtcLsp.Import hiding (takeMVar, putMVar, newEmptyMVar)
import UnliftIO.Concurrent (ThreadId, forkFinally, putMVar, threadDelay)
import BtcLsp.Import (newEmptyMVar)
import qualified LndClient.RPC.Silent as Lnd
import BtcLsp.Storage.Model.LnChan (persistChannelUpdates, persistChannelList)
import LndClient
import LndClient.Data.ListChannels

forkThread :: MonadUnliftIO m => m () -> m (ThreadId, MVar ())
forkThread proc = do
  handle <- newEmptyMVar
  tid <- forkFinally proc (\_ -> putMVar handle ())
  return (tid, handle)


syncChannelList :: (Storage m) => LndEnv -> m ()
syncChannelList lnd = do
  res <- Lnd.listChannels lnd (ListChannelsRequest False False False False Nothing)
  case res of
    Right chs -> void $ persistChannelList chs
    Left _ -> pure ()

watchChannelEvents :: (Storage m, KatipContext m) => LndEnv -> m (ThreadId, MVar ())
watchChannelEvents lnd = forkThread $ withRunInIO act
    where
      act run = do
        _ <- Lnd.subscribeChannelEvents (run . persistChannelUpdates) lnd
        pure ()

applyListChannelWatcher :: (Env m) => m ()
applyListChannelWatcher = do
  lnd <- getLspLndEnv
  void $ syncChannelList lnd
  void $ threadDelay $ 60 * 1000000
  applyListChannelWatcher


apply :: (Env m) => m ()
apply = do
  lnd <- getLspLndEnv
  withRunInIO $ \run -> do
    _ <- Lnd.subscribeChannelEvents (run . persistChannelUpdates) lnd
    pure ()
