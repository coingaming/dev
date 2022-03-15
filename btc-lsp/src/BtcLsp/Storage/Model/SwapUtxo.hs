module BtcLsp.Storage.Model.SwapUtxo
  (createSql, getFundsBySwapIdSql, markAsUsedForChanFundingSql) where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql

createSql ::
  ( MonadIO m,
    Psql.PersistStoreWrite backend,
    Psql.BaseBackend backend ~ Psql.SqlBackend
  ) =>
  BlockId ->
  SwapIntoLnId ->
  TxId 'Funding ->
  Vout 'Funding ->
  MSat ->
  ReaderT backend m (Psql.Key SwapUtxo)
createSql blockId swapId txid vout amount = do
  let ent =
        SwapUtxo
          { swapUtxoSwapIntoLnId = swapId,
            swapUtxoBlockId = blockId,
            swapUtxoTxid = txid,
            swapUtxoVout = vout,
            swapUtxoAmount = amount,
            swapUtxoStatus = SwapUtxoFirstSeen
          }
  Psql.insert ent

-- select swap_into_ln_id, sum(amount) from swap_utxo group by swap_into_ln_id;
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
    Psql.set row [SwapUtxoStatus Psql.=. Psql.val SwapUtxoUsedForChanFunding]
    Psql.where_ $ row Psql.^. SwapUtxoId `Psql.in_` Psql.valList ids
