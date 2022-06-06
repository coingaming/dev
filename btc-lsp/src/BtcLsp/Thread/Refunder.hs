{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.Refunder
  ( apply,
    SendUtxosResult (..),
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
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
import qualified LndClient.Data.OutPoint as OP
import qualified LndClient.Data.PublishTransaction as PT
import qualified LndClient.Data.ReleaseOutput as RO
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc

apply :: (Env m) => m ()
apply =
  forever $
    runSql SwapUtxo.getUtxosForRefundSql
      <&> groupBy (\a b -> swpId a == swpId b)
      >>= mapM_ processRefund
      >> sleep (MicroSecondsDelay 1000000)
  where
    swpId = entityKey . snd

data RefundUtxo = RefundUtxo
  { getOutPoint :: OP.OutPoint,
    getAmt :: MSat,
    getLockId :: Maybe UtxoLockId
  }
  deriving stock (Show, Generic)

data SendUtxosResult = SendUtxosResult
  { getGetDecTrx :: Btc.DecodedRawTransaction,
    getTotalAmt :: MSat,
    getFee :: MSat
  }

instance Out RefundUtxo

newtype TxLabel = TxLabel
  { unTxLabel :: Text
  }
  deriving newtype
    ( Show,
      Eq,
      Ord,
      Semigroup
    )

sendUtxos ::
  ( Env m
  ) =>
  Math.SatPerVbyte ->
  [RefundUtxo] ->
  OnChainAddress 'Refund ->
  TxLabel ->
  ExceptT Failure m SendUtxosResult
sendUtxos feeRate utxos addr txLabel = do
  estFee <-
    tryFailureT $
      Math.trxEstFee
        (Math.InQty . fromIntegral $ length utxos)
        (Math.OutQty 1)
        feeRate
  let finalOutputAmt = totalInputsAmt - estFee
  when (finalOutputAmt < Math.trxDustLimit) . throwE $
    FailureInternal $
      "Final output amount "
        <> inspectPlain finalOutputAmt
        <> " = "
        <> inspectPlain totalInputsAmt
        <> " - "
        <> inspectPlain estFee
        <> " is below dust limit "
        <> inspectPlain Math.trxDustLimit
  releaseUtxosLocks utxos
  estPsbt <-
    withLndT
      Lnd.fundPsbt
      ($ newFundPsbtReq feeRate utxos addr finalOutputAmt)
  releaseUtxosPsbtLocks $ FP.lockedUtxos estPsbt
  finPsbt <-
    withLndT
      Lnd.finalizePsbt
      ($ FNP.FinalizePsbtRequest (FP.fundedPsbt estPsbt) mempty)
  decodedTrx <-
    withBtcT
      Btc.decodeRawTransaction
      ($ toHex $ FNP.rawFinalTx finPsbt)
  ptRes <-
    withLndT
      Lnd.publishTransaction
      ( $
          PT.PublishTransactionRequest
            (FNP.rawFinalTx finPsbt)
            $ unTxLabel txLabel
      )
  if null $ PT.publishError ptRes
    then pure $ SendUtxosResult decodedTrx totalInputsAmt estFee
    else throwE $ FailureInternal "Failed to publish refund transaction"
  where
    totalInputsAmt =
      sum $ getAmt <$> utxos

releaseUtxosLocks ::
  ( Env m
  ) =>
  [RefundUtxo] ->
  ExceptT Failure m ()
releaseUtxosLocks =
  mapM_
    ( \refUtxo ->
        whenJust
          (getLockId refUtxo)
          ( \lid ->
              void $
                withLndT
                  Lnd.releaseOutput
                  ( $
                      RO.ReleaseOutputRequest
                        (coerce lid)
                        (Just $ getOutPoint refUtxo)
                  )
          )
    )

releaseUtxosPsbtLocks ::
  ( Env m
  ) =>
  [FP.UtxoLease] ->
  ExceptT Failure m ()
releaseUtxosPsbtLocks =
  mapM_ (\r -> withLndT Lnd.releaseOutput ($ toROR r))
  where
    toROR (FP.UtxoLease id' op _) =
      RO.ReleaseOutputRequest id' (Just op)

newFundPsbtReq ::
  Math.SatPerVbyte ->
  [RefundUtxo] ->
  OnChainAddress 'Refund ->
  MSat ->
  FP.FundPsbtRequest
newFundPsbtReq feeRate utxos' (OnChainAddress outAddr) est = do
  let mtpl =
        FP.TxTemplate
          (getOutPoint <$> utxos')
          (M.fromList [(outAddr, est)])
  FP.FundPsbtRequest
    { FP.account = mempty,
      FP.template = mtpl,
      FP.minConfs = 2,
      FP.spendUnconfirmed = False,
      FP.fee =
        FP.SatPerVbyte
          . ceiling
          $ Math.unSatPerVbyte feeRate
    }

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
          Math.minFeeRate
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
    refUtxos = toOutPointAmt . entityVal . fst <$> utxos

toOutPointAmt :: SwapUtxo -> RefundUtxo
toOutPointAmt x =
  RefundUtxo
    ( OP.OutPoint
        (coerce $ swapUtxoTxid x)
        (coerce $ swapUtxoVout x)
    )
    (coerce $ swapUtxoAmount x)
    (swapUtxoLockId x)
