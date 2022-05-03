module BtcLsp.Thread.LnChanWatcher
  ( watchChannelEvents,
    forkThread,
    applyPoll,
    applySub,
  )
where

import BtcLsp.Import (newEmptyMVar)
import BtcLsp.Import hiding (newEmptyMVar, putMVar, takeMVar)
import BtcLsp.Storage.Model.LnChan
  ( persistChannelUpdates,
    persistOpenedChannels,
  )
import LndClient
import LndClient.Data.ListChannels
import qualified LndClient.RPC.Silent as LndSilent
import UnliftIO.Concurrent
  ( ThreadId,
    forkFinally,
    putMVar,
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
    LndSilent.listChannels
      lnd
      (ListChannelsRequest False False False False Nothing)
  case res of
    Right chs -> void $ persistOpenedChannels chs
    Left {} -> pure ()

--
-- TODO : verify why this is needed?
--
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
        LndSilent.subscribeChannelEvents
          (void . run . persistChannelUpdates)
          lnd
      act run

applyPoll :: (Env m) => m ()
applyPoll =
  forever $
    getLspLndEnv
      >>= syncChannelList
      >> sleep (MicroSecondsDelay $ 60 * 1000000)

applySub :: (Env m) => m ()
applySub =
  forever $ do
    lnd <- getLspLndEnv
    withRunInIO $ \run -> do
      void $
        LndSilent.subscribeChannelEvents
          (void . run . persistChannelUpdates)
          lnd
    sleep . MicroSecondsDelay $ 5 * 1000000
