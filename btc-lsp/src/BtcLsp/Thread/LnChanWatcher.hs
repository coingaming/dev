{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.LnChanWatcher
  ( applyPoll,
    applySub,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified LndClient.Data.Channel as Lnd hiding (outputIndex)
import qualified LndClient.Data.ChannelBackup as Bak
import qualified LndClient.Data.ChannelPoint as Lnd
import LndClient.Data.ListChannels
import qualified LndClient.RPC.Silent as LndSilent

syncChannelList :: (Env m) => m ()
syncChannelList = do
  res <-
    runExceptT $ do
      cs <-
        withLndT
          LndSilent.listChannels
          ($ ListChannelsRequest False False False False Nothing)
      --
      -- TODO : can optimize this, backups are immutable,
      -- so can poll and write them only once per channel.
      --
      mapM
        ( \ch -> do
            let cp =
                  Lnd.channelPoint ch
            let getBakT =
                  Just . Bak.chanBackup
                    <$> withLndT
                      LndSilent.exportChannelBackup
                      ($ Lnd.channelPoint ch)
            mCh <-
              lift
                . (entityVal <<$>>)
                . runSql
                . LnChan.getByChannelPointSql (Lnd.fundingTxId cp)
                $ Lnd.outputIndex cp
            mBak <-
              case mCh of
                Nothing -> getBakT
                Just (LnChan {lnChanBak = Nothing}) -> getBakT
                Just {} -> pure Nothing
            pure
              ( ch,
                mBak
              )
        )
        cs
  case res of
    Left e ->
      $(logTM) ErrorS . logStr $
        "SyncChannelList failure " <> inspect e
    Right xs ->
      runSql . void $
        LnChan.persistOpenedChannelsSql xs

applyPoll :: (Env m) => m ()
applyPoll =
  forever $
    syncChannelList
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
