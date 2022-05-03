{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.LnChan
  ( createIgnoreSql,
    getByChannelPoint,
    persistChannelUpdates,
    persistOpenedChannels,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified LndClient.Data.Channel as Channel
import qualified LndClient.Data.Channel as Lnd
import qualified LndClient.Data.ChannelPoint as ChannelPoint
import qualified LndClient.Data.ChannelPoint as Lnd
import qualified LndClient.Data.CloseChannel as CloseChannel
import qualified LndClient.Data.CloseChannel as Lnd
import qualified LndClient.Data.SubscribeChannelEvents as Lnd

createIgnoreSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
createIgnoreSql swapId txid vout = do
  ct <- getCurrentTime
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Just swapId,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanExtId = Nothing,
        lnChanNumUpdates = 0,
        lnChanStatus = LnChanStatusPendingOpen,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = MSat 0,
        lnChanTotalSatoshisSent = MSat 0
      }
    [ LnChanSwapIntoLnId Psql.=. Psql.val (Just swapId),
      LnChanUpdatedAt Psql.=. Psql.val ct
    ]

getByChannelPoint ::
  ( Storage m
  ) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Entity LnChan))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChan txid vout

persistOpenedChannels ::
  ( Storage m,
    Traversable t
  ) =>
  t Lnd.Channel ->
  m (t (Entity LnChan))
persistOpenedChannels cs = do
  ct <- getCurrentTime
  runSql
    . forM cs
    $ upsertChannel ct Nothing

--
-- TODO : do not update in case where
-- channel data has not been changed,
-- this way we can detect how long channel
-- is active or inactive. Use LnChanNumUpdates
-- as activity indicator.
--
upsertChannel ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Maybe LnChanStatus ->
  Lnd.Channel ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
upsertChannel ct mSS chan =
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanExtId = extId,
        lnChanNumUpdates = upd,
        lnChanStatus = ss,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = rcv,
        lnChanTotalSatoshisSent = sent
      }
    [ LnChanExtId
        Psql.=. Psql.val extId,
      LnChanStatus
        Psql.=. Psql.val ss,
      LnChanNumUpdates
        Psql.=. Psql.val upd,
      LnChanTotalSatoshisSent
        Psql.=. Psql.val sent,
      LnChanTotalSatoshisReceived
        Psql.=. Psql.val rcv,
      LnChanUpdatedAt
        Psql.=. Psql.val ct
    ]
  where
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
    upd = Channel.numUpdates chan
    sent = Channel.totalSatoshisSent chan
    rcv = Channel.totalSatoshisReceived chan
    extId = Just $ Channel.chanId chan

upsertChannelPoint ::
  ( MonadIO m
  ) =>
  UTCTime ->
  LnChanStatus ->
  Lnd.ChannelPoint ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
upsertChannelPoint ct ss (Lnd.ChannelPoint txid vout) =
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanExtId = Nothing,
        lnChanClosingTxId = Nothing,
        lnChanNumUpdates = 0,
        lnChanStatus = ss,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = MSat 0,
        lnChanTotalSatoshisSent = MSat 0
      }
    [ LnChanStatus
        Psql.=. Psql.val ss,
      LnChanUpdatedAt
        Psql.=. Psql.val ct
    ]

closedChannelUpsert ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Lnd.ChannelCloseSummary ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
closedChannelUpsert ct close =
  Psql.upsertBy
    (UniqueLnChan fundTxId fundVout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = fundTxId,
        lnChanFundingVout = fundVout,
        lnChanClosingTxId = closeTxId,
        lnChanExtId = extId,
        lnChanNumUpdates = 0,
        lnChanStatus = ss,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
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
  where
    ss = LnChanStatusClosed
    cp = CloseChannel.chPoint close
    fundTxId = ChannelPoint.fundingTxId cp
    fundVout = ChannelPoint.outputIndex cp
    closeTxId = Just $ CloseChannel.closingTxId close
    extId = Just $ CloseChannel.chanId close

persistChannelUpdates ::
  ( KatipContext m,
    Storage m
  ) =>
  Lnd.ChannelEventUpdate ->
  m (Entity LnChan)
persistChannelUpdates (Lnd.ChannelEventUpdate channelEvent _) = do
  $(logTM) DebugS . logStr $ inspect channelEvent
  ct <- getCurrentTime
  runSql $ case channelEvent of
    Lnd.ChannelEventUpdateChannelOpenChannel chan ->
      upsertChannel ct (Just LnChanStatusOpened) chan
    Lnd.ChannelEventUpdateChannelActiveChannel cp ->
      upsertChannelPoint ct LnChanStatusActive cp
    Lnd.ChannelEventUpdateChannelInactiveChannel cp ->
      upsertChannelPoint ct LnChanStatusInactive cp
    Lnd.ChannelEventUpdateChannelClosedChannel close ->
      closedChannelUpsert ct close
    Lnd.ChannelEventUpdateChannelFullyResolved cp ->
      upsertChannelPoint ct LnChanStatusFullyResolved cp
    Lnd.ChannelEventUpdateChannelPendingOpenChannel
      (Lnd.PendingUpdate txid vout) ->
        upsertChannelPoint ct LnChanStatusPendingOpen $
          Lnd.ChannelPoint txid vout
