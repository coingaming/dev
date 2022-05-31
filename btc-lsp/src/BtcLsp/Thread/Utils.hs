module BtcLsp.Thread.Utils
  (swapUtxoToPsbtUtxo)
where

import BtcLsp.Import
import qualified LndClient.Data.OutPoint as OP

swapUtxoToPsbtUtxo :: SwapUtxo -> PsbtUtxo
swapUtxoToPsbtUtxo x =
  PsbtUtxo
    ( OP.OutPoint
        (coerce $ swapUtxoTxid x)
        (coerce $ swapUtxoVout x)
    )
    (coerce $ swapUtxoAmount x)
    (swapUtxoLockId x)

