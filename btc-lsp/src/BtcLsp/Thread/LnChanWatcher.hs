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
  whenRight res $
    runSql
      . void
      . LnChan.persistOpenedChannelsSql

applyPoll :: (Env m) => m ()
applyPoll =
  forever $
    getLspLndEnv
      >>= syncChannelList
      >> sleep300ms

applySub :: (Env m) => m ()
applySub =
  forever $ do
    lnd <- getLspLndEnv
    withRunInIO $ \run -> do
      void $
        LndSilent.subscribeChannelEvents
          ( void
              . run
              . runSql
              . LnChan.persistChannelUpdateSql
          )
          lnd
    sleep300ms
