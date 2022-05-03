module BtcLsp.Storage.Model.SwapUtxo
  ( createManySql,
    getFundsBySwapIdSql,
    markAsUsedForChanFundingSql,
    markRefundedSql,
    getUtxosForRefundSql,
    getUtxosBySwapIdSql,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createManySql ::
  ( Storage m
  ) =>
  [SwapUtxo] ->
  ReaderT Psql.SqlBackend m ()
createManySql =
  Psql.putMany

getFundsBySwapIdSql ::
  ( Storage m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m [Entity SwapUtxo]
getFundsBySwapIdSql swapId = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( ( row Psql.^. SwapUtxoStatus
              Psql.==. Psql.val SwapUtxoFirstSeen
          )
            Psql.&&. ( row Psql.^. SwapUtxoSwapIntoLnId
                         Psql.==. Psql.val swapId
                     )
        )
      pure row

markAsUsedForChanFundingSql ::
  ( Storage m
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
  ( Storage m
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
  ( Storage m
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
  ( Storage m
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
