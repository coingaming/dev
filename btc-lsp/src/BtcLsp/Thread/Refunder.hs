{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.Refunder (apply) where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import BtcLsp.Storage.Model.SwapUtxo (getUtxosForRefundSql, markRefundedSql)
import qualified Data.ByteString.Base16 as B16
import Data.List (groupBy)
import qualified Data.Map as M
import LndClient (txIdParser)
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.Data.OutPoint as OP
import qualified LndClient.Data.PublishTransaction as PT
import qualified LndClient.Data.ReleaseOutput as RO
import LndClient.RPC.Katip
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc

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

debugLog :: (KatipContext m) => Text -> m ()
debugLog = $(logTM) DebugS . logStr

errorLog :: (KatipContext m) => Text -> m ()
errorLog = $(logTM) ErrorS . logStr

getOutPoint :: (OP.OutPoint, MSat, Maybe ByteString) -> OP.OutPoint
getOutPoint (u, _, _) = u

getAmt :: (OP.OutPoint, MSat, Maybe ByteString) -> MSat
getAmt (_, a, _) = a

getLockId :: (OP.OutPoint, MSat, Maybe ByteString) -> Maybe ByteString
getLockId (_, _, l) = l

sendUtxosWithMinFee ::
  (Env m) =>
  SendUtxoConfig ->
  [(OP.OutPoint, MSat, Maybe ByteString)] ->
  Text ->
  Text ->
  ExceptT Failure m (Btc.DecodedRawTransaction, MSat, MSat)
sendUtxosWithMinFee cfg utxos addr txLabel = do
  when (estimateAmt <= dustLimit cfg) $ liftIO $ fail "Total utxos amount is below dust limit"
  mapM_
    ( \r -> case getLockId r of
        Just l -> void $ withLndT releaseOutput ($ RO.ReleaseOutputRequest l (Just $ getOutPoint r))
        _ -> pure ()
    )
    utxos
  ePsbt <- withLndT fundPsbt ($ ePsbtReq)
  finPsbt <- withLndT finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt ePsbt) "")
  decodedETx <- withBtcT Btc.decodeRawTransaction ($ toHex $ FNP.rawFinalTx finPsbt)
  let fee = MSat $ fromInteger (satPerVbyte cfg * 1000 * Btc.decVsize decodedETx)
  void $ releaseUtxosPsbtLocks (FP.lockedUtxos ePsbt)
  let rPsbtReq = fundPsbtReq utxos addr fee
  rPsbt <- withLndT fundPsbt ($ rPsbtReq)
  finRPsbt <- withLndT finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt rPsbt) "")
  decodedFTx <- withBtcT Btc.decodeRawTransaction ($ toHex $ FNP.rawFinalTx finRPsbt)
  ptRes <- withLndT publishTransaction ($ PT.PublishTransactionRequest (FNP.rawFinalTx finRPsbt) txLabel)
  if null $ PT.publishError ptRes
    then pure (decodedFTx, totalUtxoAmt, fee)
    else liftIO $ fail "Failed to publish refund transaction"
  where
    ePsbtReq = fundPsbtReq utxos addr estimateAmt
    estimateAmt = totalUtxoAmt - estimateFee cfg
    totalUtxoAmt = sum $ getAmt <$> utxos
    releaseUtxosPsbtLocks lutxos =
      mapM_ (\r -> withLndT releaseOutput ($ toROR r)) lutxos
      where
        toROR (FP.UtxoLease id' op _) = RO.ReleaseOutputRequest id' (Just op)
    fundPsbtReq utxos' outAddr fee = do
      let amt' :: Word64 = coerce (totalUtxoAmt - fee)
      let r = MSat $ (* 1000) $ fromInteger $ ceiling (toRational amt' / 1000)
      let mtpl = FP.TxTemplate (getOutPoint <$> utxos') (M.fromList [(outAddr, r)])
      FP.FundPsbtRequest "" mtpl 2 False (FP.SatPerVbyte 1)

sendUtxos ::
  (Env m) => [(OP.OutPoint, MSat, Maybe ByteString)] -> Text -> Text -> ExceptT Failure m (Btc.DecodedRawTransaction, MSat, MSat)
sendUtxos = sendUtxosWithMinFee defSendUtxoConfig

processRefund :: Env m => [(Entity SwapUtxo, Entity SwapIntoLn)] -> m ()
processRefund utxos@(x : _) =
  let refAddr = swapIntoLnRefundAddress $ entityVal $ snd x
      utxos' = toOutPointAmt . entityVal . fst <$> utxos
   in do
        debugLog $ "Start refunding utxos:" <> inspect utxos' <> " to address:" <> inspect refAddr
        r <- runExceptT $ sendUtxos utxos' (coerce refAddr) ("refund to " <> coerce refAddr)
        whenLeft r $ \e ->
          errorLog $
            "Failed to refund utxos:"
              <> inspect utxos'
              <> " to address:"
              <> inspect refAddr
              <> " with error:"
              <> inspect e
        whenRight r $ \(rtx, total, fee) -> do
          debugLog $
            "Successfully refunded utxos: " <> inspect utxos' <> " to address:" <> inspect refAddr
              <> " on chain rawTx:"
              <> inspect rtx
              <> " amount: "
              <> inspect total
              <> " with fee:"
              <> inspect fee
          case txIdParser $ Btc.unTransactionID $ Btc.decTxId rtx of
            Right rtxid -> void $ runSql $ markRefundedSql (entityKey . fst <$> utxos) (from rtxid)
            Left e -> errorLog $ "Failed to convert txid:" <> inspect e
processRefund _ = pure ()

toOutPointAmt :: SwapUtxo -> (OP.OutPoint, MSat, Maybe ByteString)
toOutPointAmt x =
  (OP.OutPoint (coerce $ swapUtxoTxid x) (coerce $ swapUtxoVout x), coerce $ swapUtxoAmount x, swapUtxoLockId x)

apply :: (Env m) => m ()
apply =
  runSql getUtxosForRefundSql
    <&> groupBy (\a b -> swpId a == swpId b) >>= mapM_ processRefund
  where
    swpId = entityKey . snd
