module BtcLsp.Thread.LnChanWatcher
  ( applyPoll,
    applySub,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import LndClient
import LndClient.Data.ListChannels
import qualified LndClient.RPC.Silent as LndSilent

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
    Right chs -> void $ LnChan.persistOpenedChannels chs
    Left {} -> pure ()

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
          (void . run . LnChan.persistChannelUpdates)
          lnd
    sleep . MicroSecondsDelay $ 5 * 1000000
