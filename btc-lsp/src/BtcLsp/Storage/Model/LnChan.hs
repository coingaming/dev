{-# LANGUAGE TemplateHaskell #-}
module BtcLsp.Storage.Model.LnChan
  ( createIgnore,
    getByChannelPoint,
    persistChannelUpdates,
    persistChannelList
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified LndClient.Data.Channel as Lnd
import qualified LndClient.Data.ChannelPoint as Lnd
import Database.Persist
import qualified LndClient.Data.CloseChannel as Lnd
import qualified LndClient.Data.SubscribeChannelEvents as Lnd

createIgnore ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  LnChanStatus ->
  m (Entity LnChan)
createIgnore swapId txid vout ss = runSql $ do
  ct <- getCurrentTime
  Psql.upsertBy
    (UniqueLnChan txid vout)
    (this ct)
    --
    -- TODO : this update is redundant, but upsertBy is
    -- not working with mempty update argument -
    -- probably it's a bug in Esqueleto implementation,
    -- check it in latest version, and if not fixed -
    -- report issue or just fix it.
    --
    -- UPDATE : reported in github
    -- https://github.com/bitemyapp/esqueleto/issues/294
    --
    [ LnChanFundingTxId Psql.=. Psql.val txid,
      LnChanFundingVout Psql.=. Psql.val vout
    ]
  where
    this ct0 =
      LnChan
        { lnChanSwapIntoLnId = Just swapId,
          lnChanFundingTxId = txid,
          lnChanFundingVout = vout,
          lnChanClosingTxId = Nothing,
          lnChanNumUpdates = 0,
          lnChanStatus = ss,
          lnChanInsertedAt = ct0,
          lnChanUpdatedAt = ct0,
          lnChanTotalSatoshisReceived = MSat 0,
          lnChanTotalSatoshisSent = MSat 0
        }

getByChannelPoint ::
  (Env m) =>
  TxId 'Funding ->
  Vout 'Funding ->
  m (Maybe (Entity LnChan))
getByChannelPoint txid vout =
  runSql
    . Psql.getBy
    $ UniqueLnChan txid vout


persistChannelList :: (Storage m, Traversable t) => t Lnd.Channel -> m (t (Entity LnChan))
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
          lnChanStatus = if active then LnChanStatusActive else LnChanStatusInactive,
          lnChanInsertedAt = now,
          lnChanUpdatedAt = now,
          lnChanTotalSatoshisReceived = tsent,
          lnChanTotalSatoshisSent = trec
        }

pendingOpenChannelInsert :: (
  PersistStoreWrite backend,
  BaseBackend backend ~ Psql.SqlBackend, MonadIO m) => UTCTime -> Lnd.PendingUpdate 'Funding -> ReaderT backend m (Psql.Key LnChan)
pendingOpenChannelInsert now (Lnd.PendingUpdate txid out)
    = insert $ LnChan Nothing txid out Nothing 0 (MSat 0) (MSat 0) LnChanStatusPendingOpen now now

openChannelUpdate :: (PersistQueryWrite backend, MonadIO m,
 BaseBackend backend ~ Psql.SqlBackend) => Lnd.Channel -> ReaderT backend m ()
openChannelUpdate (Lnd.Channel _ (Lnd.ChannelPoint txid out) _ _ _ _ _ _ _ _ _)
    = updateWhere [LnChanFundingTxId ==. txid, LnChanFundingVout ==. out]
          [LnChanStatus =. LnChanStatusOpened, LnChanNumUpdates +=. 1]

activeChannelUpdate :: (PersistQueryWrite backend, MonadIO m,
 BaseBackend backend ~ Psql.SqlBackend) => Lnd.ChannelPoint -> ReaderT backend m ()
activeChannelUpdate (Lnd.ChannelPoint txid out)
    = updateWhere [LnChanFundingTxId ==. txid, LnChanFundingVout ==. out]
          [LnChanStatus =. LnChanStatusActive, LnChanNumUpdates +=. 1]

inactiveChannelUpdate :: (PersistQueryWrite backend, MonadIO m,
 BaseBackend backend ~ Psql.SqlBackend) => Lnd.ChannelPoint -> ReaderT backend m ()
inactiveChannelUpdate (Lnd.ChannelPoint txid out)
    = updateWhere [LnChanFundingTxId ==. txid, LnChanFundingVout ==. out]
          [LnChanStatus =. LnChanStatusInactive, LnChanNumUpdates +=. 1]

closedChannelUpdate :: (PersistQueryWrite backend, MonadUnliftIO m,
 BaseBackend backend ~ Psql.SqlBackend) => Lnd.ChannelCloseSummary -> ReaderT backend m ()
closedChannelUpdate (Lnd.ChannelCloseSummary _remotePubkey (Lnd.ChannelPoint txid out) _settledBalance closeTxId)
    = updateWhere [LnChanFundingTxId ==. txid, LnChanFundingVout ==. out]
          [LnChanStatus =. LnChanStatusClosed,
          LnChanClosingTxId =. Just closeTxId,
          LnChanNumUpdates +=. 1]

fullyResolvedChannelUpdate :: (PersistQueryWrite backend, MonadIO m,
 BaseBackend backend ~ Psql.SqlBackend) => Lnd.ChannelPoint -> ReaderT backend m ()
fullyResolvedChannelUpdate (Lnd.ChannelPoint txid out)
    = updateWhere [LnChanFundingTxId ==. txid, LnChanFundingVout ==. out]
          [LnChanStatus =. LnChanStatusInactive, LnChanNumUpdates +=. 1]


persistChannelUpdates :: (KatipContext m, Storage m) => Lnd.ChannelEventUpdate -> m ()
persistChannelUpdates (Lnd.ChannelEventUpdate channelEvent _) = do
  $(logTM) DebugS $ logStr $ inspect channelEvent
  now <- getCurrentTime
  case channelEvent of
    Lnd.ChannelEventUpdateChannelOpenChannel x -> runSql $ openChannelUpdate x
    Lnd.ChannelEventUpdateChannelActiveChannel x -> runSql $ activeChannelUpdate x
    Lnd.ChannelEventUpdateChannelInactiveChannel x -> runSql $ inactiveChannelUpdate x
    Lnd.ChannelEventUpdateChannelClosedChannel x -> runSql $ closedChannelUpdate x
    Lnd.ChannelEventUpdateChannelFullyResolved x -> runSql $ fullyResolvedChannelUpdate x
    Lnd.ChannelEventUpdateChannelPendingOpenChannel x -> void $ runSql $ pendingOpenChannelInsert now x
