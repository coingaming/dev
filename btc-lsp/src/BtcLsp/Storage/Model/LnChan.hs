{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.LnChan
  ( createUpdateSql,
    getByChannelPointSql,
    persistChannelUpdateSql,
    persistOpenedChannelsSql,
    getBySwapIdSql,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Util as Util
import qualified LndClient.Data.Channel as Channel
import qualified LndClient.Data.Channel as Lnd
import qualified LndClient.Data.ChannelBackup as Lnd
import qualified LndClient.Data.ChannelPoint as ChannelPoint
import qualified LndClient.Data.ChannelPoint as Lnd
import qualified LndClient.Data.CloseChannel as CloseChannel
import qualified LndClient.Data.CloseChannel as Lnd
import qualified LndClient.Data.SubscribeChannelEvents as Lnd

createUpdateSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
createUpdateSql swapId txid vout = do
  ct <- getCurrentTime
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Just swapId,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanExtId = Nothing,
        lnChanBak = Nothing,
        lnChanStatus = LnChanStatusPendingOpen,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTransactedAt = ct,
        lnChanTotalSatoshisReceived = MSat 0,
        lnChanTotalSatoshisSent = MSat 0
      }
    [ LnChanSwapIntoLnId Psql.=. Psql.val (Just swapId),
      LnChanUpdatedAt Psql.=. Psql.val ct
    ]

getByChannelPointSql ::
  ( Storage m
  ) =>
  TxId 'Funding ->
  Vout 'Funding ->
  ReaderT Psql.SqlBackend m (Maybe (Entity LnChan))
getByChannelPointSql txid =
  Util.lockByUnique
    . UniqueLnChan txid

getBySwapIdSql ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m [Entity LnChan]
getBySwapIdSql swpId =
  Psql.select $
    Psql.from $ \c -> do
      Psql.where_ (c Psql.^. LnChanSwapIntoLnId Psql.==. Psql.val (Just swpId))
      pure c

lazyUpdateSwapStatus ::
  ( MonadIO m
  ) =>
  Entity LnChan ->
  ReaderT Psql.SqlBackend m ()
lazyUpdateSwapStatus (Entity _ chanVal) = do
  whenJust (lnChanSwapIntoLnId chanVal) $ \swapKey ->
    when (lnChanStatus chanVal == LnChanStatusActive)
      . void
      . SwapIntoLn.withLockedRowSql swapKey (== SwapWaitingChan)
      . const
      $ SwapIntoLn.updateSucceededWithoutInvoiceSql swapKey

upsertChannelSql ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Maybe LnChanStatus ->
  Lnd.Channel ->
  Maybe Lnd.SingleChanBackupBlob ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
upsertChannelSql ct mSS chan mBak =
  maybeM
    (upsert mempty)
    (upsert . getOtherUpdates)
    $ Util.lockByUnique uniq
  where
    upsert otherUpdates = do
      chanEnt <-
        Psql.upsertBy
          uniq
          LnChan
            { lnChanSwapIntoLnId = Nothing,
              lnChanFundingTxId = txid,
              lnChanFundingVout = vout,
              lnChanClosingTxId = Nothing,
              lnChanExtId = extId,
              lnChanBak = mBak,
              lnChanStatus = ss,
              lnChanInsertedAt = ct,
              lnChanUpdatedAt = ct,
              lnChanTransactedAt = ct,
              lnChanTotalSatoshisReceived = rcv,
              lnChanTotalSatoshisSent = sent
            }
          $ [ LnChanExtId
                Psql.=. Psql.val extId,
              LnChanStatus
                Psql.=. Psql.val ss,
              LnChanUpdatedAt
                Psql.=. Psql.val ct
            ]
            <> otherUpdates
      lazyUpdateSwapStatus chanEnt
      pure chanEnt
    getOtherUpdates (Entity _ x) =
      if lnChanTotalSatoshisSent x == sent
        && lnChanTotalSatoshisReceived x == rcv
        then mempty
        else
          [ LnChanTotalSatoshisSent
              Psql.=. Psql.val sent,
            LnChanTotalSatoshisReceived
              Psql.=. Psql.val rcv,
            LnChanTransactedAt
              Psql.=. Psql.val ct
          ]
    ss =
      fromMaybe
        ( if Channel.active chan
            then LnChanStatusActive
            else LnChanStatusInactive
        )
        mSS
    cp = Channel.channelPoint chan
    txid = ChannelPoint.fundingTxId cp
    vout = ChannelPoint.outputIndex cp
    sent = Channel.totalSatoshisSent chan
    rcv = Channel.totalSatoshisReceived chan
    extId = Just $ Channel.chanId chan
    uniq = UniqueLnChan txid vout

upsertChannelPointSql ::
  ( MonadIO m
  ) =>
  UTCTime ->
  LnChanStatus ->
  Lnd.ChannelPoint ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
upsertChannelPointSql ct ss (Lnd.ChannelPoint txid vout) =
  maybeM
    upsert
    (const upsert)
    $ Util.lockByUnique uniq
  where
    uniq = UniqueLnChan txid vout
    upsert = do
      chanEnt <-
        Psql.upsertBy
          uniq
          LnChan
            { lnChanSwapIntoLnId = Nothing,
              lnChanFundingTxId = txid,
              lnChanFundingVout = vout,
              lnChanExtId = Nothing,
              lnChanBak = Nothing,
              lnChanClosingTxId = Nothing,
              lnChanStatus = ss,
              lnChanInsertedAt = ct,
              lnChanUpdatedAt = ct,
              lnChanTransactedAt = ct,
              lnChanTotalSatoshisReceived = MSat 0,
              lnChanTotalSatoshisSent = MSat 0
            }
          [ LnChanStatus
              Psql.=. Psql.val ss,
            LnChanUpdatedAt
              Psql.=. Psql.val ct
          ]
      lazyUpdateSwapStatus chanEnt
      pure chanEnt

closedChannelUpsert ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Lnd.ChannelCloseSummary ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
closedChannelUpsert ct close =
  maybeM
    upsert
    (const upsert)
    $ Util.lockByUnique uniq
  where
    upsert =
      Psql.upsertBy
        uniq
        LnChan
          { lnChanSwapIntoLnId = Nothing,
            lnChanFundingTxId = fundTxId,
            lnChanFundingVout = fundVout,
            lnChanClosingTxId = closeTxId,
            lnChanExtId = extId,
            lnChanBak = Nothing,
            lnChanStatus = ss,
            lnChanInsertedAt = ct,
            lnChanUpdatedAt = ct,
            lnChanTransactedAt = ct,
            lnChanTotalSatoshisReceived = MSat 0,
            lnChanTotalSatoshisSent = MSat 0
          }
        [ LnChanExtId
            Psql.=. Psql.val extId,
          LnChanClosingTxId
            Psql.=. Psql.val closeTxId,
          LnChanStatus
            Psql.=. Psql.val ss,
          LnChanUpdatedAt
            Psql.=. Psql.val ct
        ]
    ss = LnChanStatusClosed
    cp = CloseChannel.chPoint close
    fundTxId = ChannelPoint.fundingTxId cp
    fundVout = ChannelPoint.outputIndex cp
    closeTxId = Just $ CloseChannel.closingTxId close
    extId = Just $ CloseChannel.chanId close
    uniq = UniqueLnChan fundTxId fundVout

persistChannelUpdateSql ::
  ( KatipContext m
  ) =>
  Lnd.ChannelEventUpdate ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
persistChannelUpdateSql (Lnd.ChannelEventUpdate channelEvent _) = do
  $(logTM) DebugS . logStr $ inspect channelEvent
  ct <- getCurrentTime
  case channelEvent of
    Lnd.ChannelEventUpdateChannelOpenChannel chan ->
      upsertChannelSql ct (Just LnChanStatusOpened) chan Nothing
    Lnd.ChannelEventUpdateChannelActiveChannel cp ->
      upsertChannelPointSql ct LnChanStatusActive cp
    Lnd.ChannelEventUpdateChannelInactiveChannel cp ->
      upsertChannelPointSql ct LnChanStatusInactive cp
    Lnd.ChannelEventUpdateChannelClosedChannel close ->
      closedChannelUpsert ct close
    Lnd.ChannelEventUpdateChannelFullyResolved cp ->
      upsertChannelPointSql ct LnChanStatusFullyResolved cp
    Lnd.ChannelEventUpdateChannelPendingOpenChannel
      (Lnd.PendingUpdate txid vout) ->
        upsertChannelPointSql ct LnChanStatusPendingOpen $
          Lnd.ChannelPoint txid vout

persistOpenedChannelsSql ::
  ( MonadIO m
  ) =>
  [(Lnd.Channel, Lnd.SingleChanBackupBlob)] ->
  ReaderT Psql.SqlBackend m [Entity LnChan]
persistOpenedChannelsSql cs = do
  ct <- getCurrentTime
  forM (sortOn (Channel.channelPoint . fst) cs) $
    uncurry (upsertChannelSql ct Nothing)
      . second Just
