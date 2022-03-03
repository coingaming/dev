{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Model.LnChan
  ( createIgnore,
    getByChannelPoint,
    persistChannelUpdates,
    persistChannelList,
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

createIgnore ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  m (Entity LnChan)
createIgnore swapId txid vout = runSql $ do
  ct <- getCurrentTime
  Psql.update $ \swap -> do
    Psql.set
      swap
      [ SwapIntoLnStatus
          Psql.=. Psql.val SwapWaitingChan,
        SwapIntoLnUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      swap Psql.^. SwapIntoLnId
        Psql.==. Psql.val swapId
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Just swapId,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanNumUpdates = 0,
        lnChanStatus = LnChanStatusPendingOpen,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = MSat 0,
        lnChanTotalSatoshisSent = MSat 0
      }
    --
    -- TODO : txid + vout update was redundant, but upsertBy is
    -- not working with mempty update argument -
    -- probably it's a bug in Esqueleto implementation,
    -- check it in latest version, and if not fixed -
    -- report issue or just fix it.
    --
    -- UPDATE : reported in github
    -- https://github.com/bitemyapp/esqueleto/issues/294
    --
    [ LnChanSwapIntoLnId Psql.=. Psql.val (Just swapId)
    ]

getByChannelPoint ::
  (Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Entity LnChan))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChan txid vout

persistChannelList ::
  ( Storage m,
    Traversable t
  ) =>
  t Lnd.Channel ->
  m (t (Entity LnChan))
persistChannelList chs = do
  now <- getCurrentTime
  runSql $ sequence $ upsertChannel now . mapChannel now <$> chs
  where
    upsertChannel now ch@(LnChan _ txid vout _ numUpdates tsent trecv _ _ _) =
      Psql.upsertBy
        (UniqueLnChan txid vout)
        ch
        [ LnChanFundingTxId Psql.=. Psql.val txid,
          LnChanFundingVout Psql.=. Psql.val vout,
          LnChanTotalSatoshisSent Psql.=. Psql.val tsent,
          LnChanTotalSatoshisReceived Psql.=. Psql.val trecv,
          LnChanNumUpdates Psql.=. Psql.val numUpdates,
          LnChanUpdatedAt Psql.=. Psql.val now
        ]
    mapChannel now (Lnd.Channel _ (Lnd.ChannelPoint txid vout) _ _ _ _ active _ tsent trec numUpdates) =
      LnChan
        { lnChanSwapIntoLnId = Nothing,
          lnChanFundingTxId = txid,
          lnChanFundingVout = vout,
          lnChanClosingTxId = Nothing,
          lnChanNumUpdates = numUpdates,
          lnChanStatus =
            if active
              then LnChanStatusActive
              else LnChanStatusInactive,
          lnChanInsertedAt = now,
          lnChanUpdatedAt = now,
          lnChanTotalSatoshisReceived = tsent,
          lnChanTotalSatoshisSent = trec
        }

pendingOpenChanUpsert ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Lnd.PendingUpdate 'Funding ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
pendingOpenChanUpsert ct (Lnd.PendingUpdate txid vout) =
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
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
  where
    ss = LnChanStatusPendingOpen

channelUpsert ::
  ( MonadIO m
  ) =>
  UTCTime ->
  Lnd.Channel ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
channelUpsert ct chan =
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
        lnChanClosingTxId = Nothing,
        lnChanNumUpdates = upd,
        lnChanStatus = LnChanStatusPendingOpen,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = rcv,
        lnChanTotalSatoshisSent = sent
      }
    [ LnChanStatus
        Psql.=. Psql.val LnChanStatusOpened,
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
    cp = Channel.channelPoint chan
    txid = ChannelPoint.fundingTxId cp
    vout = ChannelPoint.outputIndex cp
    upd = Channel.numUpdates chan
    sent = Channel.totalSatoshisSent chan
    rcv = Channel.totalSatoshisReceived chan

channelPointUpsert ::
  ( MonadIO m
  ) =>
  Lnd.ChannelPoint ->
  LnChanStatus ->
  UTCTime ->
  ReaderT Psql.SqlBackend m (Entity LnChan)
channelPointUpsert (Lnd.ChannelPoint txid vout) ss ct =
  Psql.upsertBy
    (UniqueLnChan txid vout)
    LnChan
      { lnChanSwapIntoLnId = Nothing,
        lnChanFundingTxId = txid,
        lnChanFundingVout = vout,
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
        lnChanNumUpdates = 0,
        lnChanStatus = ss,
        lnChanInsertedAt = ct,
        lnChanUpdatedAt = ct,
        lnChanTotalSatoshisReceived = MSat 0,
        lnChanTotalSatoshisSent = MSat 0
      }
    [ LnChanClosingTxId
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

persistChannelUpdates ::
  ( KatipContext m,
    Storage m
  ) =>
  Lnd.ChannelEventUpdate ->
  m (Entity LnChan)
persistChannelUpdates (Lnd.ChannelEventUpdate channelEvent _) = do
  $(logTM) DebugS $ logStr $ inspect channelEvent
  ct <- getCurrentTime
  runSql $ case channelEvent of
    Lnd.ChannelEventUpdateChannelOpenChannel x ->
      channelUpsert ct x
    Lnd.ChannelEventUpdateChannelActiveChannel x ->
      channelPointUpsert x LnChanStatusActive ct
    Lnd.ChannelEventUpdateChannelInactiveChannel x ->
      channelPointUpsert x LnChanStatusInactive ct
    Lnd.ChannelEventUpdateChannelClosedChannel x ->
      closedChannelUpsert ct x
    Lnd.ChannelEventUpdateChannelFullyResolved x ->
      channelPointUpsert x LnChanStatusInactive ct
    Lnd.ChannelEventUpdateChannelPendingOpenChannel x ->
      pendingOpenChanUpsert ct x
