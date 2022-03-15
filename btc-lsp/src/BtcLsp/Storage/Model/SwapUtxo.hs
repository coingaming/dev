module BtcLsp.Storage.Model.SwapUtxo
  (createSql)
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql


createSql :: (MonadIO m, Psql.PersistStoreWrite backend,
 Psql.BaseBackend backend ~ Psql.SqlBackend) =>
  BlockId
  -> SwapIntoLnId
  -> TxId 'Funding
  -> Vout 'Funding
  -> MSat
  -> ReaderT backend m (Psql.Key SwapUtxo)
createSql blockId swapId txid vout amount = do
  let ent = SwapUtxo {
      swapUtxoSwapIntoLnId = swapId,
      swapUtxoBlockId = blockId,
      swapUtxoTxid = txid,
      swapUtxoVout = vout,
      swapUtxoAmount = amount,
      swapUtxoStatus = SwapUtxoFirstSeen
    }
  Psql.insert ent
