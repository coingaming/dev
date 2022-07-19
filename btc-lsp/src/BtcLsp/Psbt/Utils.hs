module BtcLsp.Psbt.Utils
  ( swapUtxoToPsbtUtxo,
    psbtShim,
    fundPsbtReq,
    openChannelReq,
    psbtVerifyReq,
    psbtFinalizeReq,
    finalizePsbt,
    unspendUtxoLookup,
    shimCancelReq,
    releaseUtxosPsbtLocks,
    releaseUtxosLocks,
    newLockId,
    lockUtxo,
    lockUtxos,
  )
where

import BtcLsp.Import
import qualified Data.ByteString.Lazy as L
import qualified Data.Digest.Pure.SHA as SHA
  ( bytestringDigest,
    sha256,
  )
import qualified Data.Map as M
import qualified LndClient as Lnd
import qualified LndClient.Data.FinalizePsbt as FNP
import qualified LndClient.Data.FundPsbt as FP
import qualified LndClient.Data.FundingPsbtFinalize as FPF
import qualified LndClient.Data.FundingPsbtVerify as FSS
import qualified LndClient.Data.FundingShimCancel as FSC
import qualified LndClient.Data.FundingStateStep as FSS
import qualified LndClient.Data.LeaseOutput as LO
import qualified LndClient.Data.ListUnspent as LU
import qualified LndClient.Data.OpenChannel as Lnd
import qualified LndClient.Data.OutPoint as OP
import qualified LndClient.Data.PsbtShim as PS
import qualified LndClient.Data.ReleaseOutput as RO
import qualified LndClient.RPC.Katip as Lnd
import qualified Universum

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
psbtShim pcid =
  PS.PsbtShim
    { PS.pendingChanId = pcid,
      PS.basePsbt = Nothing,
      PS.noPublish = False
    }

fundPsbtReq :: [OP.OutPoint] -> Map Text MSat -> FP.FundPsbtRequest
fundPsbtReq inputs outputs =
  FP.FundPsbtRequest
    { FP.account = "",
      FP.template = FP.TxTemplate inputs outputs,
      FP.minConfs = 0,
      FP.spendUnconfirmed = True,
      FP.fee = FP.SatPerVbyte 1
    }

openChannelReq ::
  Lnd.PendingChannelId ->
  Lnd.NodePubKey ->
  Money 'Lsp 'Ln 'Gain ->
  Money 'Usr 'Ln 'Gain ->
  Privacy ->
  Lnd.OpenChannelRequest
openChannelReq pcid toNode totalFundAmt pushAmt private =
  Lnd.OpenChannelRequest
    { Lnd.nodePubkey = toNode,
      Lnd.localFundingAmount = coerce totalFundAmt,
      Lnd.pushMSat = Just $ coerce pushAmt,
      Lnd.targetConf = Nothing,
      Lnd.mSatPerByte = Nothing,
      Lnd.private = Just $ private == Private,
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
shimCancelReq pcid =
  FSS.FundingStateStepShimCancelRequest $
    FSC.FundingShimCancel {FSC.pendingChanId = pcid}

finalizePsbt :: (Env m) => Lnd.Psbt -> ExceptT Failure m FNP.FinalizePsbtResponse
finalizePsbt psbt = withLndT Lnd.finalizePsbt ($ FNP.FinalizePsbtRequest (coerce psbt) "")

unspendUtxoLookup :: (Env m) => ExceptT Failure m (Map OP.OutPoint LU.Utxo)
unspendUtxoLookup = do
  allUtxos <- LU.utxos <$> withLndT Lnd.listUnspent ($ LU.ListUnspentRequest 0 maxBound "")
  pure $ foldr (\u acc -> M.insert (LU.outpoint u) u acc) M.empty allUtxos

releaseUtxosPsbtLocks ::
  ( Env m
  ) =>
  [PsbtUtxo] ->
  ExceptT Failure m ()
releaseUtxosPsbtLocks =
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

releaseUtxosLocks ::
  ( Env m
  ) =>
  [FP.UtxoLease] ->
  ExceptT Failure m ()
releaseUtxosLocks =
  mapM_ (\r -> withLndT Lnd.releaseOutput ($ toROR r))
  where
    toROR (FP.UtxoLease id' op _) =
      RO.ReleaseOutputRequest id' (Just op)

newLockId :: OP.OutPoint -> UtxoLockId
newLockId u =
  UtxoLockId
    . L.toStrict
    . SHA.bytestringDigest
    . SHA.sha256
    $ txid <> ":" <> vout
  where
    txid = L.fromStrict . coerce $ OP.txid u
    vout = Universum.show $ OP.outputIndex u

lockUtxo :: (Env m) => OP.OutPoint -> ExceptT Failure m FP.UtxoLease
lockUtxo op = do
  void $
    withLndT
      Lnd.leaseOutput
      ($ LO.LeaseOutputRequest (coerce lockId) (Just op) expS)
  pure
    FP.UtxoLease
      { FP.id = coerce lockId,
        FP.expiration = expS,
        FP.outpoint = op
      }
  where
    expS :: Word64 = 3600 * 24 * 365 * 10
    lockId = newLockId op

lockUtxos :: (Env m) => [OP.OutPoint] -> ExceptT Failure m [FP.UtxoLease]
lockUtxos = mapM lockUtxo
