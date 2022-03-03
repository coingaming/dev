module BtcLsp.Thread.LnChanWatcher
  ( watchChannelEvents,
    forkThread,
    apply,
    applyListChannelWatcher,
  )
where

import BtcLsp.Import (newEmptyMVar)
import BtcLsp.Import hiding (newEmptyMVar, putMVar, takeMVar)
import BtcLsp.Storage.Model.LnChan
  ( persistChannelList,
    persistChannelUpdates,
  )
import LndClient
import LndClient.Data.ListChannels
import qualified LndClient.RPC.Silent as Lnd
import UnliftIO.Concurrent
  ( ThreadId,
    forkFinally,
    putMVar,
    threadDelay,
  )

forkThread ::
  ( MonadUnliftIO m
  ) =>
  m () ->
  m (ThreadId, MVar ())
forkThread proc = do
  handle <- newEmptyMVar
  tid <- forkFinally proc (const $ putMVar handle ())
  return (tid, handle)

syncChannelList ::
  ( Storage m
  ) =>
  LndEnv ->
  m ()
syncChannelList lnd = do
  res <-
    Lnd.listChannels
      lnd
      (ListChannelsRequest False False False False Nothing)
  case res of
    Right chs -> void $ persistChannelList chs
    Left {} -> pure ()

watchChannelEvents ::
  ( Storage m,
    KatipContext m
  ) =>
  LndEnv ->
  m (ThreadId, MVar ())
watchChannelEvents lnd =
  forkThread $
    withRunInIO act
  where
    act run = do
      void $
        Lnd.subscribeChannelEvents
          (void . run . persistChannelUpdates)
          lnd
      act run

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
    void $
      Lnd.subscribeChannelEvents
        (void . run . persistChannelUpdates)
        lnd
