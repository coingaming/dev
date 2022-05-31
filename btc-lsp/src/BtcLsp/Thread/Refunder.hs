{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.Refunder
  ( apply,
    SendUtxosResult (..),
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import BtcLsp.Math.OnChain (roundWord64ToMSat)
import qualified BtcLsp.Math.OnChain as Math
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
  ( getUtxosForRefundSql,
    updateRefundedSql,
  )
import Data.List (groupBy)
import qualified Data.Map as M
import LndClient (txIdParser)
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.Data.PublishTransaction as PT
import qualified LndClient.Data.ReleaseOutput as RO
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc
import BtcLsp.Thread.Utils (swapUtxoToPsbtUtxo)

apply :: (Env m) => m ()
apply =
  forever $
    runSql SwapUtxo.getUtxosForRefundSql
      <&> groupBy (\a b -> swpId a == swpId b)
      >>= mapM_ processRefund
      >> sleep (MicroSecondsDelay 1000000)
  where
    swpId = entityKey . snd

data SendUtxoConfig = SendUtxoConfig
  { estimateFee :: MSat,
    satPerVbyte :: Integer
  }

defSendUtxoConfig :: SendUtxoConfig
defSendUtxoConfig =
  SendUtxoConfig
    { estimateFee = MSat $ 500 * 1000,
      satPerVbyte = 1
    }

data SendUtxosResult = SendUtxosResult
  { getGetDecTrx :: Btc.DecodedRawTransaction,
    getTotalAmt :: MSat,
    getFee :: MSat
  }

newtype TxLabel
  = TxLabel Text
  deriving newtype
    ( Show,
      Eq,
      Ord,
      Semigroup
    )

sendUtxosWithMinFee ::
  (Env m) =>
  SendUtxoConfig ->
  [PsbtUtxo] ->
  OnChainAddress 'Refund ->
  TxLabel ->
  ExceptT Failure m SendUtxosResult
sendUtxosWithMinFee cfg utxos (OnChainAddress addr) (TxLabel txLabel) = do
  when (estimateAmt < Math.trxDustLimit) . throwE $
    FailureInternal $
      "Total utxos amount "
        <> inspectPlain estimateAmt
        <> " is below dust limit "
        <> inspectPlain Math.trxDustLimit
  mapM_
    ( \refUtxo ->
        whenJust
          (getLockId refUtxo)
          ( \lid ->
              void $
                withLndT
                  Lnd.releaseOutput
                  ($ RO.ReleaseOutputRequest (coerce lid) (Just $ getOutPoint refUtxo))
          )
    )
    utxos
  ePsbt <- withLndT Lnd.fundPsbt ($ ePsbtReq)
  finPsbt <- withLndT Lnd.finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt ePsbt) "")
  decodedETx <- withBtcT Btc.decodeRawTransaction ($ toHex $ FNP.rawFinalTx finPsbt)
  let fee = MSat $ fromInteger (satPerVbyte cfg * 1000 * Btc.decVsize decodedETx)
  void $ releaseUtxosPsbtLocks (FP.lockedUtxos ePsbt)
  let rPsbtReq = fundPsbtReq utxos addr fee
  rPsbt <- withLndT Lnd.fundPsbt ($ rPsbtReq)
  finRPsbt <- withLndT Lnd.finalizePsbt ($ FNP.FinalizePsbtRequest (FP.fundedPsbt rPsbt) "")
  decodedFTx <- withBtcT Btc.decodeRawTransaction ($ toHex $ FNP.rawFinalTx finRPsbt)
  ptRes <- withLndT Lnd.publishTransaction ($ PT.PublishTransactionRequest (FNP.rawFinalTx finRPsbt) txLabel)
  if null $ PT.publishError ptRes
    then pure $ SendUtxosResult decodedFTx totalUtxoAmt fee
    else throwE $ FailureInternal "Failed to publish refund transaction"
  where
    ePsbtReq = fundPsbtReq utxos addr estimateAmt
    estimateAmt = totalUtxoAmt - estimateFee cfg
    totalUtxoAmt = sum $ getAmt <$> utxos
    releaseUtxosPsbtLocks lutxos =
      mapM_ (\r -> withLndT Lnd.releaseOutput ($ toROR r)) lutxos
      where
        toROR (FP.UtxoLease id' op _) = RO.ReleaseOutputRequest id' (Just op)
    fundPsbtReq utxos' outAddr fee = do
      let amt' :: Word64 = coerce (totalUtxoAmt - fee)
      let r = roundWord64ToMSat amt'
      let mtpl = FP.TxTemplate (getOutPoint <$> utxos') (M.fromList [(outAddr, r)])
      FP.FundPsbtRequest
        { FP.account = "",
          FP.template = mtpl,
          FP.minConfs = 2,
          FP.spendUnconfirmed = False,
          FP.fee = FP.SatPerVbyte 1
        }

sendUtxos ::
  ( Env m
  ) =>
  [PsbtUtxo] ->
  OnChainAddress 'Refund ->
  TxLabel ->
  ExceptT Failure m SendUtxosResult
sendUtxos =
  sendUtxosWithMinFee defSendUtxoConfig

processRefund ::
  ( Env m
  ) =>
  [(Entity SwapUtxo, Entity SwapIntoLn)] ->
  m ()
processRefund [] = pure ()
processRefund utxos@(x : _) = do
  res <- runSql
    . SwapIntoLn.withLockedRowSql
      (entityKey $ snd x)
      (`elem` swapStatusFinal)
    . const
    $ do
      $(logTM) DebugS . logStr $
        "Start refunding utxos:"
          <> inspect refUtxos
          <> " to address:"
          <> inspect refAddr
      eitherM
        ( \e -> do
            Psql.transactionUndo
            $(logTM) ErrorS . logStr $
              "Failed to refund utxos:"
                <> inspect refUtxos
                <> " to address:"
                <> inspect refAddr
                <> " with error:"
                <> inspect e
        )
        ( \(SendUtxosResult rtx total fee) -> do
            $(logTM) DebugS . logStr $
              "Successfully refunded utxos: "
                <> inspect refUtxos
                <> " to address:"
                <> inspect refAddr
                <> " on chain rawTx:"
                <> inspect rtx
                <> " amount: "
                <> inspect total
                <> " with fee:"
                <> inspect fee
            case txIdParser
              . Btc.unTransactionID
              $ Btc.decTxId rtx of
              Right rtxid ->
                SwapUtxo.updateRefundedSql
                  (entityKey . fst <$> utxos)
                  (from rtxid)
              Left e -> do
                Psql.transactionUndo
                $(logTM) ErrorS . logStr $
                  "Failed to convert txid:" <> inspect e
        )
        . lift
        . runExceptT
        $ sendUtxos
          refUtxos
          (coerce refAddr)
          (TxLabel "refund to " <> coerce refAddr)
  whenLeft res $
    $(logTM) ErrorS
      . logStr
      . ("No refund due to wrong status " <>)
      . inspect
  where
    refAddr = swapIntoLnRefundAddress $ entityVal $ snd x
    refUtxos = swapUtxoToPsbtUtxo . entityVal . fst <$> utxos
