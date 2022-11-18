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
import BtcLsp.Psbt.Utils
  ( releaseUtxosLocks,
    releaseUtxosPsbtLocks,
    swapUtxoToPsbtUtxo,
  )
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
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc

apply :: (Env m) => m ()
apply =
  forever $ do
    runSql $
      SwapUtxo.getUtxosForRefundSql
        >>= mapM_ processRefundSql
          . groupBy (\a b -> swpId a == swpId b)
    sleep300ms
  where
    swpId = entityKey . snd

data SendUtxosResult = SendUtxosResult
  { getGetDecTrx :: Btc.DecodedRawTransaction,
    getTotalAmt :: Msat,
    getFee :: Msat
  }

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
  [PsbtUtxo] ->
  OnChainAddress 'Refund ->
  TxLabel ->
  ExceptT Failure m SendUtxosResult
sendUtxos feeRate utxos addr txLabel = do
  inQty <- tryFromT "SendUtxos length" $ length utxos
  let estFee =
        Math.trxEstFee
          (Math.InQty inQty)
          (Math.OutQty 1)
          feeRate
  let finalOutputAmt = totalInputsAmt - estFee
  when (finalOutputAmt < Math.trxDustLimit) . throwE $
    FailureInt . FailurePrivate $
      "Final output amount "
        <> inspectPlain finalOutputAmt
        <> " = "
        <> inspectPlain totalInputsAmt
        <> " - "
        <> inspectPlain estFee
        <> " is below dust limit "
        <> inspectPlain Math.trxDustLimit
  releaseUtxosPsbtLocks utxos
  estPsbt <-
    withLndT
      Lnd.fundPsbt
      ($ newFundPsbtReq feeRate utxos addr finalOutputAmt)
  releaseUtxosLocks $ FP.lockedUtxos estPsbt
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
    else throwE . FailureInt $ FailurePrivate "Failed to publish refund transaction"
  where
    totalInputsAmt =
      sum $ getAmt <$> utxos

newFundPsbtReq ::
  Math.SatPerVbyte ->
  [PsbtUtxo] ->
  OnChainAddress 'Refund ->
  Msat ->
  FP.FundPsbtRequest
newFundPsbtReq feeRate utxos' outAddr est = do
  let mtpl =
        FP.TxTemplate
          (getOutPoint <$> utxos')
          (M.fromList [(unOnChainAddress outAddr, est)])
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

processRefundSql ::
  ( Env m
  ) =>
  [(Entity SwapUtxo, Entity SwapIntoLn)] ->
  ReaderT Psql.SqlBackend m ()
processRefundSql [] = pure ()
processRefundSql utxos@(x : _) = do
  res <- SwapIntoLn.withLockedRowSql
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
          (TxLabel $ "refund to " <> unOnChainAddress refAddr)
  whenLeft res $
    $(logTM) ErrorS
      . logStr
      . ("No refund due to wrong status " <>)
      . inspect
  where
    refAddr = swapIntoLnRefundAddress $ entityVal $ snd x
    refUtxos = swapUtxoToPsbtUtxo . entityVal . fst <$> utxos
