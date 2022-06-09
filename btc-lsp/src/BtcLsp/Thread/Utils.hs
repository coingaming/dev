module BtcLsp.Thread.Utils
  (
    swapUtxoToPsbtUtxo, psbtShim,
    fundPsbtReq, openChannelReq,
    psbtVerifyReq, psbtFinalizeReq,
    finalizePsbt, unspendUtxoLookup,
    shimCancelReq
  )
where

import BtcLsp.Import
import qualified LndClient.Data.OutPoint as OP
import qualified LndClient.Data.OpenChannel as Lnd
import qualified LndClient as Lnd
import qualified LndClient.Data.PsbtShim as PS
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.RPC.Katip as Lnd
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundingStateStep as FSS
import qualified LndClient.Data.FundingPsbtVerify as FSS
import qualified LndClient.Data.FundingPsbtFinalize as FPF
import qualified LndClient.Data.OutPoint as Lnd
import qualified LndClient.Data.ListUnspent as LU
import qualified Data.Map as M
import qualified LndClient.Data.FundingShimCancel as FSC


swapUtxoToPsbtUtxo :: SwapUtxo -> PsbtUtxo
swapUtxoToPsbtUtxo x =
  PsbtUtxo
    ( OP.OutPoint
        (coerce $ swapUtxoTxid x)
        (coerce $ swapUtxoVout x)
    )
    (coerce $ swapUtxoAmount x)
    (swapUtxoLockId x)


psbtShim :: Lnd.PendingChannelId -> PS.PsbtShim
psbtShim pcid = PS.PsbtShim {
  PS.pendingChanId = pcid,
  PS.basePsbt = Nothing,
  PS.noPublish = False
}

fundPsbtReq :: FP.TxTemplate -> FP.FundPsbtRequest
fundPsbtReq tmpl = FP.FundPsbtRequest {
  FP.account = "",
  FP.template = tmpl,
  FP.minConfs = 2,
  FP.spendUnconfirmed = False,
  FP.fee = FP.SatPerVbyte 1
}

openChannelReq :: Lnd.PendingChannelId -> Lnd.NodePubKey -> MSat -> MSat -> Lnd.OpenChannelRequest
openChannelReq pcid toNode localAmt pushAmt =
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

shimCancelReq :: Lnd.PendingChannelId -> FSS.FundingStateStepRequest
shimCancelReq pcid = FSS.FundingStateStepShimCancelRequest $
  FSC.FundingShimCancel { FSC.pendingChanId = pcid }

finalizePsbt :: (Env m) => Lnd.Psbt -> ExceptT Failure m FNP.FinalizePsbtResponse
finalizePsbt psbt = withLndT Lnd.finalizePsbt ($ FNP.FinalizePsbtRequest (coerce psbt) "")

unspendUtxoLookup :: (Env m) => ExceptT Failure m (Map Lnd.OutPoint LU.Utxo)
unspendUtxoLookup = do
  allUtxos <- LU.utxos <$> withLndT Lnd.listUnspent ($ LU.ListUnspentRequest 0 maxBound "")
  pure $ foldr (\u acc-> M.insert (LU.outpoint u) u acc) M.empty allUtxos
