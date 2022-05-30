module BtcLsp.Storage.Model.SwapUtxo
  ( createManySql,
    getSpendableUtxosBySwapIdSql,
    updateUnspentChanReserveSql,
    updateSpentChanSql,
    updateSpentChanSwappedSql,
    updateRefundedSql,
    updateOrphanSql,
    getUtxosForRefundSql,
    getUtxosBySwapIdSql,
    updateRefundBlockIdSql,
    revertRefundedSql,
  )
where

import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql

createManySql ::
  ( MonadIO m
  ) =>
  [SwapUtxo] ->
  ReaderT Psql.SqlBackend m ()
createManySql us =
  Psql.upsertManyWhere
    us
    [Psql.copyField SwapUtxoUpdatedAt]
    mempty
    mempty

getSpendableUtxosBySwapIdSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m [Entity SwapUtxo]
getSpendableUtxosBySwapIdSql swapId = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( ( row Psql.^. SwapUtxoSwapIntoLnId
              Psql.==. Psql.val swapId
          )
            Psql.&&. ( row Psql.^. SwapUtxoStatus
                         `Psql.in_` Psql.valList
                           [ SwapUtxoUnspent,
                             SwapUtxoUnspentChanReserve
                           ]
                     )
        )
      pure row

updateUnspentChanReserveSql ::
  ( MonadIO m
  ) =>
  [SwapUtxoId] ->
  ReaderT Psql.SqlBackend m RowQty
updateUnspentChanReserveSql ids = do
  ct <- getCurrentTime
  from <<$>> Psql.updateCount $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus
          Psql.=. Psql.val SwapUtxoUnspentChanReserve,
        SwapUtxoUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapUtxoId
          `Psql.in_` Psql.valList ids
      )
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     `Psql.in_` Psql.valList
                       [ SwapUtxoUnspent,
                         SwapUtxoUnspentChanReserve
                       ]
                 )

updateSpentChanSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateSpentChanSql id0 = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoSpentChan,
        SwapUtxoUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapUtxoSwapIntoLnId
          Psql.==. Psql.val id0
      )
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     `Psql.in_` Psql.valList
                       [ SwapUtxoUnspentChanReserve
                       ]
                 )

updateSpentChanSwappedSql ::
  ( MonadIO m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateSpentChanSwappedSql id0 = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoSpentChanSwapped,
        SwapUtxoUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapUtxoSwapIntoLnId
          Psql.==. Psql.val id0
      )
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     `Psql.in_` Psql.valList
                       [ SwapUtxoSpentChan
                       ]
                 )

updateRefundedSql ::
  ( MonadIO m
  ) =>
  [SwapUtxoId] ->
  TxId 'Funding ->
  ReaderT Psql.SqlBackend m ()
updateRefundedSql ids rTxId = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoSpentRefund,
        SwapUtxoRefundTxId Psql.=. Psql.val (Just rTxId),
        SwapUtxoUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. SwapUtxoId
          `Psql.in_` Psql.valList ids
      )
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     `Psql.in_` Psql.valList
                       [ SwapUtxoUnspent,
                         SwapUtxoUnspentChanReserve
                       ]
                 )

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
                             [ SwapUtxoUnspent,
                               SwapUtxoUnspentChanReserve
                             ]
                       )
          )
            Psql.||. ( ( swap Psql.^. SwapIntoLnStatus
                           Psql.==. Psql.val SwapSucceeded
                       )
                         Psql.&&. ( utxo Psql.^. SwapUtxoStatus
                                      Psql.==. Psql.val
                                        SwapUtxoUnspent
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

updateRefundBlockIdSql ::
  ( MonadIO m
  ) =>
  BlockId ->
  ReaderT Psql.SqlBackend m ()
updateRefundBlockIdSql blkId = do
  utxos <- Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( row Psql.^. SwapUtxoBlockId
            Psql.==. Psql.val blkId
        )
      pure row
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoRefundBlockId
          Psql.=. Psql.val (Just blkId)
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoRefundTxId
        `Psql.in_` Psql.valList (Just <$> (swapUtxoTxid . entityVal <$> utxos))
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     Psql.==. Psql.val SwapUtxoSpentRefund
                 )

updateOrphanSql ::
  ( MonadIO m
  ) =>
  [BlockId] ->
  ReaderT Psql.SqlBackend m ()
updateOrphanSql ids = do
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

revertRefundedSql :: (MonadIO m) => [BlockId] -> ReaderT Psql.SqlBackend m ()
revertRefundedSql ids = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus
          Psql.=. Psql.val SwapUtxoUnspent,
        SwapUtxoRefundTxId
          Psql.=. Psql.val Nothing,
        SwapUtxoRefundBlockId
          Psql.=. Psql.val Nothing,
        SwapUtxoUpdatedAt
          Psql.=. Psql.val ct
      ]
    Psql.where_ $
      row Psql.^. SwapUtxoRefundBlockId
        `Psql.in_` Psql.valList (Just <$> ids)
        Psql.&&. ( row Psql.^. SwapUtxoStatus
                     Psql.==. Psql.val SwapUtxoSpentRefund
                 )
