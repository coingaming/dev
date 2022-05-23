module BtcLsp.Storage.Model.SwapUtxo
  ( createManySql,
    getFundsBySwapIdSql,
    markAsUsedForChanFundingSql,
    markRefundedSql,
    markOrphanBlocksSql,
    getUtxosForRefundSql,
    getUtxosBySwapIdSql,
    putRefundBlockIdIfNeededSql,
    revertRefundedDueToReorgSql,
  )
where

import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql

createManySql ::
  ( MonadIO m
  ) =>
  [SwapUtxo] ->
  ReaderT Psql.SqlBackend m ()
createManySql =
  Psql.putMany

getFundsBySwapIdSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m [Entity SwapUtxo]
getFundsBySwapIdSql swapId = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( ( row Psql.^. SwapUtxoStatus
              `Psql.in_` Psql.valList
                [ SwapUtxoFirstSeen,
                  SwapUtxoUsedForChanFunding
                ]
          )
            Psql.&&. ( row Psql.^. SwapUtxoSwapIntoLnId
                         Psql.==. Psql.val swapId
                     )
        )
      pure row

markAsUsedForChanFundingSql ::
  ( MonadIO m
  ) =>
  [SwapUtxoId] ->
  ReaderT Psql.SqlBackend m ()
markAsUsedForChanFundingSql ids = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus
          Psql.=. Psql.val SwapUtxoUsedForChanFunding,
        SwapUtxoUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoId
        `Psql.in_` Psql.valList ids

markRefundedSql ::
  ( MonadIO m
  ) =>
  [SwapUtxoId] ->
  TxId 'Funding ->
  ReaderT Psql.SqlBackend m ()
markRefundedSql ids rTxId = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoRefunded,
        SwapUtxoRefundTxId Psql.=. Psql.val (Just rTxId),
        SwapUtxoUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoId
        `Psql.in_` Psql.valList ids

getUtxosForRefundSql ::
  ( MonadIO m
  ) =>
  ReaderT
    Psql.SqlBackend
    m
    [(Entity SwapUtxo, Entity SwapIntoLn)]
getUtxosForRefundSql =
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` utxo) -> do
      Psql.on
        ( (swap Psql.^. SwapIntoLnId)
            Psql.==. (utxo Psql.^. SwapUtxoSwapIntoLnId)
        )
      Psql.where_
        ( ( ( swap Psql.^. SwapIntoLnStatus
                Psql.==. Psql.val SwapExpired
            )
              Psql.&&. ( utxo Psql.^. SwapUtxoStatus
                           `Psql.in_` Psql.valList
                             [ SwapUtxoFirstSeen,
                               SwapUtxoUsedForChanFunding
                             ]
                       )
          )
            Psql.||. ( ( swap Psql.^. SwapIntoLnStatus
                           Psql.==. Psql.val SwapSucceeded
                       )
                         Psql.&&. ( utxo Psql.^. SwapUtxoStatus
                                      Psql.==. Psql.val
                                        SwapUtxoFirstSeen
                                  )
                     )
        )
      pure (utxo, swap)

getUtxosBySwapIdSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m [Entity SwapUtxo]
getUtxosBySwapIdSql swapId = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( row Psql.^. SwapUtxoSwapIntoLnId
            Psql.==. Psql.val swapId
        )
      pure row

putRefundBlockIdIfNeededSql :: (MonadIO m) => BlockId -> TxId 'Funding -> ReaderT Psql.SqlBackend m ()
putRefundBlockIdIfNeededSql blkId txId = do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoRefundBlockId
          Psql.=. Psql.val (Just blkId)
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoRefundTxId
        Psql.==. Psql.val (Just txId)

markOrphanBlocksSql :: (MonadIO m) => [BlockId] -> ReaderT Psql.SqlBackend m ()
markOrphanBlocksSql ids = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus
          Psql.=. Psql.val SwapUtxoOrphan,
        SwapUtxoUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoBlockId
        `Psql.in_` Psql.valList ids

revertRefundedDueToReorgSql :: (MonadIO m) => [BlockId] -> ReaderT Psql.SqlBackend m ()
revertRefundedDueToReorgSql ids = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus
          Psql.=. Psql.val SwapUtxoFirstSeen,
        SwapUtxoUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoRefundBlockId
        `Psql.in_` Psql.valList (Just <$> ids)
