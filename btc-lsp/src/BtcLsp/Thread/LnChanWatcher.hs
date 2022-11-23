{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.LnChanWatcher
  ( applyPoll,
    applySub,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified Data.Set as Set
import qualified LndClient.Data.Channel as Lnd hiding (outputIndex)
import qualified LndClient.Data.ChannelBackup as Bak
import qualified LndClient.Data.ChannelPoint as Lnd
import LndClient.Data.ClosedChannels (ClosedChannelsRequest (..))
import LndClient.Data.ListChannels
import qualified LndClient.RPC.Silent as LndSilent

syncChannelList :: (Env m) => m ()
syncChannelList = do
  res <-
    runExceptT $ do
      openedChans <-
        withLndT
          LndSilent.listChannels
          ($ ListChannelsRequest False False False False Nothing)
      --
      -- TODO : get list of channels which are opened
      -- according database status, but not in openedChans
      -- list according lnd. Need to check are they closed
      -- and update status.
      --
      openedChansBak <-
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
          openedChans
      closedChans <-
        withLndT
          LndSilent.closedChannels
          ( $
              ClosedChannelsRequest
                False
                False
                False
                False
                False
                False
          )
      nonSwapSet <- lift . runSql $ do
        void $ LnChan.persistOpenedChannelsSql openedChansBak
        void $ LnChan.persistClosedChannelsSql closedChans
        nonSwapList <- LnChan.getActiveNonSwapSql
        pure . fromList $
          ( \(Entity {entityVal = x}) ->
              Lnd.ChannelPoint
                (lnChanFundingTxId x)
                (lnChanFundingVout x)
          )
            <$> nonSwapList
      let nonSwapChans =
            filter
              ( \x ->
                  ( Lnd.channelPoint x
                      `Set.member` nonSwapSet
                  )
                    && not (Lnd.prv x)
                    && Lnd.active x
              )
              openedChans
      lift
        . monitorTotalExtOutgoingLiquidity
        . Liquidity
        . sum
        $ Lnd.localBalance <$> nonSwapChans
      lift
        . monitorTotalExtIncomingLiquidity
        . Liquidity
        . sum
        $ Lnd.remoteBalance <$> nonSwapChans
  whenLeft res $
    $logTM ErrorS . logStr
      . ("SyncChannelList failure " <>)
      . inspect @Text

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
