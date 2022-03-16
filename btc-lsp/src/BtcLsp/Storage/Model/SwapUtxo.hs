module BtcLsp.Storage.Model.SwapUtxo
  (createManySql, getFundsBySwapIdSql, markAsUsedForChanFundingSql) where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createManySql ::(Storage m) => [SwapUtxo] -> ReaderT Psql.SqlBackend m [SwapUtxoId]
createManySql = Psql.insertMany

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
    Psql.set row [
      SwapUtxoStatus Psql.=. Psql.val SwapUtxoUsedForChanFunding,
      SwapUtxoUpdatedAt Psql.=. Psql.now_ ]
    Psql.where_ $ row Psql.^. SwapUtxoId `Psql.in_` Psql.valList ids
