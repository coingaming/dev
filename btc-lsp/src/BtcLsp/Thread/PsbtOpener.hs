{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.PsbtOpener
  ()
where

-- import qualified Data.Map as M
-- import qualified LndClient.Data.FinalizePsbt as FNP
-- import qualified LndClient.Data.FundPsbt as FP
-- import qualified LndClient.Data.FundingPsbtFinalize as FPF
-- import qualified LndClient.Data.FundingPsbtVerify as FSS
-- import qualified LndClient.Data.FundingStateStep as FSS
-- import LndClient.Data.GetInfo (GetInfoResponse (..))
-- import qualified LndClient.Data.ListUnspent as LU
-- import qualified LndClient.Data.NewAddress as NA
-- import LndClient.Data.OpenChannel
-- import qualified LndClient.Data.OutPoint as OP
-- import qualified LndClient.Data.PsbtShim as PS
-- import qualified LndClient.Data.PublishTransaction as PT
-- import qualified LndClient.Data.SendCoins as SC
-- import LndClient.Import
-- import LndClient.LndTest
-- import LndClient.RPC.Katip
-- import qualified UnliftIO.STM as T
-- import LndClient.Data.ChannelPoint

-- genAddr :: (KatipContext f, MonadUnliftIO f) => LndEnv -> f Text
-- genAddr lnd =
--   fmap NA.address $
--     liftLndResult =<< newAddress lnd (NA.NewAddressRequest NA.WITNESS_PUBKEY_HASH Nothing)
--
-- findUtxosByTxId :: (KatipContext m, MonadUnliftIO m) => LndEnv -> ByteString -> m [LU.Utxo]
-- findUtxosByTxId lnd txid' = do
--   utxos <- LU.utxos <$> (liftLndResult =<< listUnspent lnd (LU.ListUnspentRequest 0 10 ""))
--   pure $ filter (\u -> txid' == OP.txid (LU.outpoint u)) utxos
--
-- psbtVerifyReq :: PendingChannelId -> Psbt -> FSS.FundingStateStepRequest
-- psbtVerifyReq pcid fp =
--   FSS.FundingStateStepPsbtVerifyRequest $
--     FSS.FundingPsbtVerify
--       { FSS.pendingChanId = pcid,
--         FSS.fundedPsbt = fp,
--         FSS.skipFinalize = False
--       }
--
-- psbtFinalizeReq :: PendingChannelId -> Psbt -> FSS.FundingStateStepRequest
-- psbtFinalizeReq pcid sp =
--   FSS.FundingStateStepPsbtFinalizeRequest $
--     FPF.FundingPsbtFinalize
--       { FPF.signedPsbt = sp,
--         FPF.pendingChanId = pcid,
--         FPF.finalRawTx = RawTx ""
--       }
--



-- fundPsbtToAddr :: LndTest m Owner => Text -> MSat -> m FP.FundPsbtResponse
-- fundPsbtToAddr fAddr amt = do
--   lndBob <- getLndEnv Bob
--   lndAlice <- getLndEnv Alice
--   addrAlice <- genAddr lndAlice
--   mine 10 Bob
--   let bankAmt = amt * 2
--   sendTrx <- liftLndResult =<< sendCoins lndBob (SC.SendCoinsRequest addrAlice bankAmt)
--   mine 2 Bob
--   txid <- liftLndResult $ txIdParser $ SC.txid sendTrx
--   utxos <- findUtxosByTxId lndAlice txid
--   --print $ "Found in Alice unspent list:" ++ show utxos
--   let temp = FP.TxTemplate (LU.outpoint <$> utxos) (M.fromList [(fAddr, amt)])
--   let fr = FP.FundPsbtRequest "" temp 2 False (FP.SatPerVbyte 2)
--   liftLndResult =<< fundPsbt lndAlice fr
--
-- signPsbt :: LndTest m Owner => FP.FundPsbtResponse -> m FNP.FinalizePsbtResponse
-- signPsbt psbt' = do
--   lndAlice <- getLndEnv Alice
--   liftLndResult =<< finalizePsbt lndAlice (FNP.FinalizePsbtRequest (FP.fundedPsbt psbt') "")
