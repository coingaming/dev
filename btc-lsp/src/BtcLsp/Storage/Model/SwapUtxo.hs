module BtcLsp.Storage.Model.SwapUtxo
  ( createManySql,
    getFundsBySwapIdSql,
    markAsUsedForChanFundingSql,
    markRefundedSql,
    getUtxosForRefundSql
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createManySql :: (Storage m) => [SwapUtxo] -> ReaderT Psql.SqlBackend m ()
createManySql =
  Psql.putMany

getFundsBySwapIdSql :: (Storage m) => SwapIntoLnId -> ReaderT Psql.SqlBackend m [Entity SwapUtxo]
getFundsBySwapIdSql swapId = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_
        ( (row Psql.^. SwapUtxoStatus Psql.==. Psql.val SwapUtxoFirstSeen)
            Psql.&&. (row Psql.^. SwapUtxoSwapIntoLnId Psql.==. Psql.val swapId)
        )
      pure row

markAsUsedForChanFundingSql :: (Storage m) => [SwapUtxoId] -> ReaderT Psql.SqlBackend m ()
markAsUsedForChanFundingSql ids = do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoUsedForChanFunding,
        SwapUtxoUpdatedAt Psql.=. Psql.now_
      ]
    Psql.where_ $ row Psql.^. SwapUtxoId `Psql.in_` Psql.valList ids

markRefundedSql:: (Storage m) => [SwapUtxoId] -> ReaderT Psql.SqlBackend m ()
markRefundedSql ids = do
  Psql.update $ \row -> do
    Psql.set
      row
      [ SwapUtxoStatus Psql.=. Psql.val SwapUtxoRefunded,
        SwapUtxoUpdatedAt Psql.=. Psql.now_
      ]
    Psql.where_ $ row Psql.^. SwapUtxoId `Psql.in_` Psql.valList ids


getUtxosForRefundSql :: (Storage m) => ReaderT Psql.SqlBackend m [(Entity SwapUtxo, Entity SwapIntoLn)]
getUtxosForRefundSql = do
  Psql.select $
    Psql.from $ \(swap `Psql.InnerJoin` utxo) -> do
      Psql.on ((swap Psql.^. SwapIntoLnId) Psql.==. (utxo Psql.^. SwapUtxoSwapIntoLnId))
      Psql.where_
        ((swap Psql.^. SwapIntoLnStatus Psql.==. Psql.val SwapFunded)
        Psql.||. (swap Psql.^. SwapIntoLnExpiresAt Psql.>. Psql.now_)
        Psql.&&. (utxo Psql.^. SwapUtxoStatus Psql.!=. Psql.val SwapUtxoRefunded))
      pure (utxo, swap)
