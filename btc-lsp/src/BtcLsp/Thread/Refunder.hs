module BtcLsp.Thread.Refunder
  (apply) where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import BtcLsp.Storage.Model.SwapUtxo (getUtxosForRefundSql, markRefundedSql)
import qualified Data.ByteString.Base16 as B16
import Data.List (groupBy)
import qualified Data.Map as M
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.Data.OutPoint as OP
import qualified LndClient.Data.PublishTransaction as PT
import qualified LndClient.Data.ReleaseOutput as RO
import LndClient.RPC.Katip
import qualified Network.Bitcoin as Btc

toHex :: ByteString -> Text
toHex = decodeUtf8 . B16.encode

data SendUtxoConfig = SendUtxoConfig
  { dustLimit :: MSat,
    estimateFee :: MSat,
    satPerVbyte :: Integer
  }

defSendUtxoConfig :: SendUtxoConfig
defSendUtxoConfig =
  SendUtxoConfig
    { dustLimit = MSat $ 20000 * 1000,
      estimateFee = MSat $ 500 * 1000,
      satPerVbyte = 1
    }

sendUtxosWithMinFee ::
  (Env m) =>
  SendUtxoConfig ->
  [(OP.OutPoint, MSat)] ->
  Text ->
  Text ->
  ExceptT Failure m PT.PublishTransactionResponse
sendUtxosWithMinFee cfg utxos addr txLabel = do
  when (estimateAmt <= dustLimit cfg) $ liftIO $ fail "Total utxos amount is below dust limit"
  let ePsbtReq = fundPsbtReq utxos addr estimateAmt
  ePsbt <- withLndT fundPsbt ($ ePsbtReq)
  finPsbt <- withLndT finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt ePsbt) "")
  decodedETx <- withBtcT Btc.decodeRawTransaction ($ toHex $ FNP.rawFinalTx finPsbt)
  let fee = MSat $ fromInteger (satPerVbyte cfg * 1000 * Btc.decVsize decodedETx)
  void $ releaseUtxos (FP.lockedUtxos ePsbt)

  let rPsbtReq = fundPsbtReq utxos addr fee
  rPsbt <- withLndT fundPsbt ($ rPsbtReq)
  finRPsbt <- withLndT finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt rPsbt) "")
  withLndT publishTransaction ($ PT.PublishTransactionRequest (FNP.rawFinalTx finRPsbt) txLabel)
  where
    estimateAmt = totalUtxoAmt - estimateFee cfg
    totalUtxoAmt = sum $ snd <$> utxos
    releaseUtxos lutxos =
      mapM_ (\r -> withLndT releaseOutput ($ toROR r)) lutxos
      where
        toROR (FP.UtxoLease id' op _) = RO.ReleaseOutputRequest id' (Just op)
    fundPsbtReq utxos' outAddr fee = do
      let amt' :: Word64 = coerce (totalUtxoAmt - fee)
      let r = MSat $ (* 1000) $ fromInteger $ ceiling (toRational amt' / 1000)
      let mtpl = FP.TxTemplate (fst <$> utxos') (M.fromList [(outAddr, r)])
      FP.FundPsbtRequest "" mtpl 2 False (FP.SatPerVbyte 1)


sendUtxos :: (Env m) => [(OP.OutPoint, MSat)] -> Text -> Text -> ExceptT Failure m PT.PublishTransactionResponse
sendUtxos = sendUtxosWithMinFee defSendUtxoConfig

processRefund :: Env m => [(Entity SwapUtxo, Entity SwapIntoLn)] -> m ()
processRefund utxos@(x:_) = do
  let swp = entityVal $ snd x
  let refAddr = swapIntoLnRefundAddress swp
  let utxos' = toOutPointAmt . entityVal . fst <$> utxos
  r <- runExceptT $ sendUtxos utxos' (coerce refAddr) ("refund to " <> coerce refAddr)
  whenRight r $ const $ do
    void $ runSql $ markRefundedSql (entityKey . fst <$> utxos)
processRefund _ = pure ()

toOutPointAmt :: SwapUtxo -> (OP.OutPoint, MSat)
toOutPointAmt x =
  (OP.OutPoint (coerce $ swapUtxoTxid x) (coerce $ swapUtxoVout x), coerce $ swapUtxoAmount x)

apply :: (Env m) => m ()
apply = do
  utxos <- runSql getUtxosForRefundSql
  let groupedBySwap = groupBy (\a b -> entityKey (snd a) == entityKey (snd b)) utxos
  mapM_ processRefund groupedBySwap





