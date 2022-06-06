{-# OPTIONS_GHC -Wno-deprecations #-}
{-# LANGUAGE TemplateHaskell #-}
module PsbtOpenerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified LndClient as Lnd
import qualified LndClient.Data.SendCoins as SendCoins
import qualified LndClient.RPC.Silent as Lnd
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
import qualified Data.ByteString.Base64 as B64
import qualified Data.Text.Encoding as T
import qualified Network.Bitcoin.RawTransaction as Btc
import qualified LndClient.Data.ReleaseOutput as RO
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.PsbtShim as PS
import qualified LndClient.Data.OpenChannel as Lnd
import qualified LndClient.Data.ChannelPoint as Lnd
import qualified UnliftIO.STM as T
import qualified LndClient.Data.FundingStateStep as FSS
import qualified LndClient.Data.FundingPsbtVerify as FSS
import qualified LndClient.Data.FundingPsbtFinalize as FPF
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.Data.NewAddress as Lnd

sendAmt :: Env m => Text -> MSat -> ExceptT Failure m ()
sendAmt addr amt =
  void $ withLndT
    Lnd.sendCoins ($ SendCoins.SendCoinsRequest {SendCoins.addr = addr, SendCoins.amount = amt})

releaseUtxosPsbtLocks :: (Env m) => [PsbtUtxo] -> ExceptT Failure m ()
releaseUtxosPsbtLocks utxos = mapM_ (\r -> withLndT Lnd.releaseOutput ($ r)) lutxos
  where
    lutxos = foldr lockedFoldFn [] utxos
    lockedFoldFn (PsbtUtxo o _ (Just lid)) acc = acc <> [RO.ReleaseOutputRequest (coerce lid) (Just o)]
    lockedFoldFn _ acc = acc


fundReq :: FP.TxTemplate -> FP.FundPsbtRequest
fundReq tmpl = FP.FundPsbtRequest {
  FP.account = "",
  FP.template = tmpl,
  FP.minConfs = 2,
  FP.spendUnconfirmed = False,
  FP.fee = FP.SatPerVbyte 1
}

autoSelectUtxos :: Env m => Text -> MSat -> ExceptT Failure m FP.FundPsbtResponse
autoSelectUtxos addr amt = withLndT Lnd.fundPsbt ($ req)
  where req = fundReq $ FP.TxTemplate [] (M.fromList [(addr, amt)])

useUtxos :: Env m => [PsbtUtxo] -> Text -> MSat -> Text -> MSat -> ExceptT Failure m FP.FundPsbtResponse
useUtxos utxos addr amt profitAddr lspFeeAmt = do
  releaseUtxosPsbtLocks utxos
  withLndT Lnd.fundPsbt ($ req)
  where req = fundReq $ FP.TxTemplate (getOutPoint <$> utxos) (M.fromList [(addr, amt), (profitAddr, lspFeeAmt)])

toNBPsbt :: ByteString -> Text
toNBPsbt x = T.decodeUtf8 $ B64.encode x

toLndPsbt :: Monad m => Text -> ExceptT Failure m ByteString
toLndPsbt x = except $ first (const $ FailureInternal "") $ B64.decode $ T.encodeUtf8 x

sumAmt :: [PsbtUtxo] -> MSat
sumAmt utxos = sum $ getAmt <$> utxos

fundChanPsbt :: (Env m) => [PsbtUtxo] -> OnChainAddress 'Fund -> OnChainAddress 'Gain -> MSat -> MSat  -> ExceptT Failure m Lnd.Psbt
fundChanPsbt utxos chanFundAddr profitAddr amt lspFeeAmt = do
  lspFunded <- autoSelectUtxos (coerce chanFundAddr) amt
  userFunded <- useUtxos utxos (coerce chanFundAddr) amt (coerce profitAddr) lspFeeAmt
  joinedPsbt <- withBtcT Btc.joinPsbts ($ [toNBPsbt $ FP.fundedPsbt lspFunded, toNBPsbt $ FP.fundedPsbt userFunded])
  lndJoinedPsbt <- toLndPsbt joinedPsbt
  trx <- withBtcT Btc.decodePsbt ($ joinedPsbt)
  $(logTM) DebugS $ logStr $ "Funding Trx" <> inspect trx
  pure $ Lnd.Psbt lndJoinedPsbt

finChanPsbt :: (Env m) => Lnd.Psbt -> ExceptT Failure m FNP.FinalizePsbtResponse
finChanPsbt psbt = withLndT Lnd.finalizePsbt ($ FNP.FinalizePsbtRequest (coerce psbt) "")

psbtShim :: Lnd.PendingChannelId -> PS.PsbtShim
psbtShim pcid = PS.PsbtShim {
  PS.pendingChanId = pcid,
  PS.basePsbt = Nothing,
  PS.noPublish = False
}

openChanReq :: Lnd.PendingChannelId -> Lnd.NodePubKey -> MSat -> MSat -> Lnd.OpenChannelRequest
openChanReq pcid toNode localAmt pushAmt =
  Lnd.OpenChannelRequest
    { Lnd.nodePubkey = toNode,
      Lnd.localFundingAmount = localAmt,
      Lnd.pushMSat = Just pushAmt,
      Lnd.targetConf = Nothing,
      Lnd.mSatPerByte = Nothing,
      Lnd.private = Nothing,
      Lnd.minHtlcMsat = Nothing,
      Lnd.remoteCsvDelay = Nothing,
      Lnd.minConfs = Nothing,
      Lnd.spendUnconfirmed = Nothing,
      Lnd.closeAddress = Nothing,
      Lnd.fundingShim = Just (psbtShim pcid)
    }

psbtVerifyReq :: Lnd.PendingChannelId -> Lnd.Psbt -> FSS.FundingStateStepRequest
psbtVerifyReq pcid fp =
  FSS.FundingStateStepPsbtVerifyRequest $
    FSS.FundingPsbtVerify
      { FSS.pendingChanId = pcid,
        FSS.fundedPsbt = fp,
        FSS.skipFinalize = False
      }

psbtFinalizeReq :: Lnd.PendingChannelId -> Lnd.Psbt -> FSS.FundingStateStepRequest
psbtFinalizeReq pcid sp =
  FSS.FundingStateStepPsbtFinalizeRequest $
    FPF.FundingPsbtFinalize
      { FPF.signedPsbt = sp,
        FPF.pendingChanId = pcid,
        FPF.finalRawTx = Lnd.RawTx ""
      }

openChannelPsbt :: Env m => [PsbtUtxo] -> NodePubKey -> OnChainAddress 'Gain -> MSat -> MSat -> ExceptT Failure m Lnd.ChannelPoint
openChannelPsbt utxos toPubKey profitAddr lspFee txFee = do
  chan <- lift T.newTChanIO
  pcid <- Lnd.newPendingChanId
  let openChannelRequest = openChanReq pcid toPubKey (2 * amt) amt

  $(logTM) DebugS $ logStr $
    "Trying to openChannel utxoAmt: " <> inspect utxoAmt <>
    " lspFee: " <> inspect lspFee <> " txFee: " <> inspect txFee <>
    " localAmt: " <> inspect amt <> " pushAmt: " <> inspect amt
  let subUpdates = void . T.atomically . T.writeTChan chan
  void $ lift . spawnLink $ withLnd (Lnd.openChannel subUpdates) ($ openChannelRequest)
  fundStep pcid chan
  where
    utxoAmt = sumAmt utxos
    amt = utxoAmt - lspFee - txFee
    fundStep pcid chan = do
      upd <- T.atomically $ T.readTChan chan
      $(logTM) DebugS $ logStr $ "Got chan status update" <> inspect upd
      case upd of
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdatePsbtFund (Lnd.ReadyForPsbtFunding faddr famt _))) -> do
          $(logTM) DebugS $ logStr $ "Chan ready for funding at addr:" <> inspect faddr <> " with amt:" <> inspect famt
          psbt' <- fundChanPsbt utxos (coerce faddr) (coerce profitAddr) amt lspFee
          void $ withLndT Lnd.fundingStateStep ($ psbtVerifyReq pcid psbt')
          sPsbtResp <- finChanPsbt psbt'
          $(logTM) DebugS $ logStr $ "Used psbt for funding:" <> inspect sPsbtResp
          void $ withLndT Lnd.fundingStateStep ($ psbtFinalizeReq pcid (Lnd.Psbt $ FNP.signedPsbt sPsbtResp))
          fundStep pcid chan
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdateChanPending p)) -> do
          $(logTM) DebugS $ logStr $ "Chan is pending... mining..." <> inspect p
          -- wait for mine
          fundStep pcid chan
        Lnd.OpenStatusUpdate _ (Just (Lnd.OpenStatusUpdateChanOpen (Lnd.ChannelOpenUpdate cp))) -> do
          $(logTM) DebugS $ logStr $ "Chan is open" <> inspect cp
          pure cp
        _ -> throwE (FailureInternal "Unexpected update")

spec :: Spec
spec =
  itEnvT "PsbtOpener Spec" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap "psbt opener test" . Just =<< getFutureTime (Lnd.Seconds 5)
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    _utxosRaw <- BlockScanner.scan
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    profitAddr <- genAddress LndLsp
    Lnd.GetInfoResponse alicePubKey _ _ <- withLndTestT LndAlice Lnd.getInfo id
    _r <- openChannelPsbt psbtUtxos alicePubKey (coerce $ Lnd.address profitAddr) (MSat 20000 * 1000) (MSat 500 * 1000)
    pure ()



