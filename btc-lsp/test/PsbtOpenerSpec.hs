{-# OPTIONS_GHC -Wno-deprecations #-}
module PsbtOpenerSpec
  ( spec,
  )
where

import BtcLsp.Import
-- import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
-- import qualified BtcLsp.Thread.Main as Main
-- import Data.List (intersect)
-- import qualified Data.Vector as V
-- import LndClient (txIdParser)
import qualified LndClient as Lnd
import qualified LndClient.Data.SendCoins as SendCoins
-- import LndClient.LndTest (liftLndResult, mine)
import qualified LndClient.RPC.Silent as Lnd
-- import qualified Network.Bitcoin as Btc
-- import qualified Network.Bitcoin.Types as Btc
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import LndClient.LndTest (mine)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified LndClient.Data.FundPsbt as FP
import qualified Data.Map as M
import BtcLsp.Thread.Utils (swapUtxoToPsbtUtxo)

sendAmt :: Env m => Text -> MSat -> ExceptT Failure m ()
sendAmt addr amt =
  void $ withLndT
    Lnd.sendCoins ($ SendCoins.SendCoinsRequest {SendCoins.addr = addr, SendCoins.amount = amt})

spec :: Spec
spec =
  itEnvT "PsbtOpener Spec" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap "psbt opener test" . Just =<< getFutureTime (Lnd.Seconds 5)
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from amt)
    void $ sendAmt (from swpAddr) (from amt)
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    _utxosRaw <- BlockScanner.scan
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    traceShowM psbtUtxos
    let autoSelectTmpl = FP.TxTemplate [] (M.fromList [(coerce swpAddr, coerce (amt * 2))])
    let autoFnd = FP.FundPsbtRequest {
      FP.account = "",
      FP.template = autoSelectTmpl,
      FP.minConfs = 2,
      FP.spendUnconfirmed = False,
      FP.fee = FP.SatPerVbyte 1
    }
    ePsbt <- withLndT Lnd.fundPsbt ($ autoFnd)
    traceShowM ePsbt
    pure ()



