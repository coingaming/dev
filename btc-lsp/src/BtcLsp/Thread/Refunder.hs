module BtcLsp.Thread.Refunder
  ()
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import qualified LndClient.Data.OutPoint as Lnd
import qualified Data.Map as M
import qualified LndClient.Data.FundPsbt as Lnd


constructRefund :: (Env m) => SwapIntoLn ->[SwapUtxo] -> m ()
constructRefund swap utxos = do
  pure ()
  where
    refundAddr = swapIntoLnRefundAddress swap
    totalUtxoAmt :: MSat
    totalUtxoAmt = sum $ coerce . swapUtxoAmount <$> utxos
    mapUtxo utxo = Lnd.OutPoint (coerce $ swapUtxoTxid utxo) (coerce $ swapUtxoVout utxo)
    outputMap = M.fromList [(from refundAddr, totalUtxoAmt)]
    tmpl = Lnd.TxTemplate (mapUtxo <$> utxos) outputMap
    req =
      Lnd.FundPsbtRequest
        { Lnd.account = "",
          Lnd.template = tmpl,
          Lnd.minConfs = 2,
          Lnd.spendUnconfirmed = False,
          Lnd.targetConf = 4
        }

