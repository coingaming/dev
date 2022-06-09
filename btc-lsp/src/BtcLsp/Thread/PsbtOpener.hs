{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.PsbtOpener (openChannelPsbt) where

import BtcLsp.Import
import qualified BtcLsp.Math.OnChain as Math
import BtcLsp.Thread.Utils
  ( finalizePsbt,
    fundPsbtReq,
    openChannelReq,
    psbtFinalizeReq,
    psbtVerifyReq,
    unspendUtxoLookup,
  )
import qualified Data.Map as M
import qualified LndClient as Lnd
import qualified LndClient.Data.ChannelPoint as Lnd
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.Data.ListUnspent as LU
import qualified LndClient.Data.OpenChannel as Lnd
import qualified LndClient.Data.ReleaseOutput as RO
import qualified LndClient.RPC.Katip as Lnd
import qualified UnliftIO.STM as T
import qualified LndClient.Data.OutPoint as OP

sumAmt :: [PsbtUtxo] -> MSat
sumAmt utxos = sum $ getAmt <$> utxos

releaseUtxosPsbtLocks :: (Env m) => [PsbtUtxo] -> ExceptT Failure m ()
releaseUtxosPsbtLocks utxos = mapM_ (\r -> withLndT Lnd.releaseOutput ($ r)) lutxos
  where
    lutxos = foldr lockedFoldFn [] utxos
    lockedFoldFn (PsbtUtxo o _ (Just lid)) acc = acc <> [RO.ReleaseOutputRequest (coerce lid) (Just o)]
    lockedFoldFn _ acc = acc

autoSelectUtxos :: Env m => OnChainAddress 'Fund -> MSat -> ExceptT Failure m FP.FundPsbtResponse
autoSelectUtxos addr amt = withLndT Lnd.fundPsbt ($ req)
  where
    req = fundPsbtReq $ FP.TxTemplate [] (M.fromList [(coerce addr, amt)])

utxoLeaseToPsbtUtxo :: Map OP.OutPoint LU.Utxo -> FP.UtxoLease -> Maybe PsbtUtxo
utxoLeaseToPsbtUtxo l ul = psbtUtxo . LU.amountSat <$> M.lookup op l
  where
    op = FP.outpoint ul
    psbtUtxo amt = PsbtUtxo {
      getAmt = amt,
      getLockId = Just . UtxoLockId $ FP.id ul,
      getOutPoint = op
    }

mapLeaseUtxosToPsbtUtxo :: Env m => [FP.UtxoLease] -> ExceptT Failure m [PsbtUtxo]
mapLeaseUtxosToPsbtUtxo lockedUtxos = do
  l <- unspendUtxoLookup
  case sequence $ utxoLeaseToPsbtUtxo l <$> lockedUtxos of
    Just us -> pure us
    Nothing -> do
      $(logTM) DebugS $ logStr $
        "Cannot find utxo in utxos:" <> inspect lockedUtxos <> " lookupMap: " <> inspect l
      throwE $ FailureInternal "Cannot find utxo in unspent list"

fundChanPsbt ::
  (Env m) =>
  [PsbtUtxo] ->
  OnChainAddress 'Fund ->
  OnChainAddress 'Gain ->
  MSat ->
  MSat -> ExceptT Failure m Lnd.Psbt
fundChanPsbt userUtxos chanFundAddr changeAddr lspFee minerFee = do
  let userFundingAmt = sumAmt userUtxos - lspFee - minerFee
  lspFunded <- autoSelectUtxos (coerce chanFundAddr) userFundingAmt
  lspUtxos <- mapLeaseUtxosToPsbtUtxo $ FP.lockedUtxos lspFunded
  let selectedInputsAmt = sumAmt lspUtxos
  $(logTM) DebugS $ logStr $ "Coins sum by lsp" <> inspect selectedInputsAmt
  let allInputs = getOutPoint <$> (userUtxos <> lspUtxos)
  let changeAmt = selectedInputsAmt - userFundingAmt + lspFee

  let outputs =
        if changeAmt > Math.trxDustLimit
          then [(coerce chanFundAddr, userFundingAmt * 2), (coerce changeAddr, changeAmt)]
          else [(coerce chanFundAddr, userFundingAmt * 2)]

  let req = fundPsbtReq $ FP.TxTemplate allInputs (M.fromList outputs)
  releaseUtxosPsbtLocks (userUtxos <> lspUtxos)
  psbt <- withLndT Lnd.fundPsbt ($ req)
  pure $ Lnd.Psbt $ FP.fundedPsbt psbt

openChannelPsbt ::
  Env m =>
  [PsbtUtxo] ->
  NodePubKey ->
  OnChainAddress 'Gain ->
  MSat ->
  MSat ->
  ExceptT Failure m Lnd.ChannelPoint
openChannelPsbt utxos toPubKey changeAddress lspFee minerFee = do
  chan <- lift T.newTChanIO
  pcid <- Lnd.newPendingChanId
  let openChannelRequest = openChannelReq pcid toPubKey (2 * amt) amt
  let subUpdates = void . T.atomically . T.writeTChan chan
  void $ lift . spawnLink $ withLnd (Lnd.openChannel subUpdates) ($ openChannelRequest)
  fundStep pcid chan
  where
    amt = sumAmt utxos - lspFee - minerFee
    fundStep pcid chan = do
      upd <- T.atomically $ T.readTChan chan
      $(logTM) DebugS $ logStr $ "Got chan status update" <> inspect upd
      case upd of
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdatePsbtFund (Lnd.ReadyForPsbtFunding faddr famt _))) -> do
          $(logTM) DebugS $ logStr $ "Chan ready for funding at addr:" <> inspect faddr <> " with amt:" <> inspect famt
          psbt' <- fundChanPsbt utxos (coerce faddr) (coerce changeAddress) lspFee minerFee
          void $ withLndT Lnd.fundingStateStep ($ psbtVerifyReq pcid psbt')
          sPsbtResp <- finalizePsbt psbt'
          $(logTM) DebugS $ logStr $ "Used psbt for funding:" <> inspect sPsbtResp
          void $ withLndT Lnd.fundingStateStep ($ psbtFinalizeReq pcid (Lnd.Psbt $ FNP.signedPsbt sPsbtResp))
          fundStep pcid chan
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdateChanPending p)) -> do
          $(logTM) DebugS $ logStr $ "Chan is pending... mining..." <> inspect p
          fundStep pcid chan
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdateChanOpen (Lnd.ChannelOpenUpdate cp))) -> do
          $(logTM) DebugS $ logStr $ "Chan is open" <> inspect cp
          pure cp
        _ -> throwE (FailureInternal "Unexpected update")
