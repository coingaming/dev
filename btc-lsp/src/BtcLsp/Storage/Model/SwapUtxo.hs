module BtcLsp.Storage.Model.SwapUtxo
  ()
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql


createNew :: (Storage m) => m ()
createNew = do
  pure ()
