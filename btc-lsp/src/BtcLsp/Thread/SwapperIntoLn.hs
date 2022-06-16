{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.SwapperIntoLn
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified Data.Set as Set
import qualified LndClient.Data.PayReq as PayReq
import qualified LndClient.Data.Payment as Payment
import qualified LndClient.Data.Peer as Peer
import qualified LndClient.Data.SendPayment as Lnd
import qualified LndClient.Data.SendPayment as SendPayment
import qualified LndClient.Data.TrackPayment as TrackPayment
import qualified LndClient.RPC.Katip as LndKatip
import qualified LndClient.RPC.Silent as LndSilent

apply :: (Env m) => m ()
apply =
  forever $ do
    ePeerList <- withLnd LndSilent.listPeers id
    whenLeft ePeerList $
      $(logTM) ErrorS
        . logStr
        . ("ListPeers procedure failed: " <>)
        . inspect
    let peerSet =
          Set.fromList $
            Peer.pubKey <$> fromRight [] ePeerList
    runSql $ do
      swapsToSettle <-
        SwapIntoLn.getSwapsWaitingLnFundSql
      mapM_
        (uncurry3 settleSwap)
        $ filter
          ( \(_, usr, _) ->
              Set.member
                (userNodePubKey $ entityVal usr)
                peerSet
          )
          swapsToSettle
    sleep300ms

settleSwap ::
  ( Env m
  ) =>
  Entity SwapIntoLn ->
  Entity User ->
  Entity LnChan ->
  ReaderT Psql.SqlBackend m ()
settleSwap swapEnt@(Entity swapKey _) userEnt chanEnt = do
  $(logTM) DebugS . logStr $
    "Trying to settle the swap = "
      <> inspect swapEnt
      <> " with channel = "
      <> inspect chanEnt
      <> " and user = "
      <> inspect userEnt
  res <- SwapIntoLn.withLockedRowSql swapKey (== SwapWaitingFundLn) $
    \swapVal -> do
      let payReq =
            from $
              swapIntoLnFundInvoice swapVal
      let sendPaymentT extId =
            SendPayment.paymentPreimage
              <$> withLndT
                LndKatip.sendPayment
                ( $
                    Lnd.SendPaymentRequest
                      { Lnd.paymentRequest =
                          payReq,
                        Lnd.amt =
                          from $
                            swapIntoLnChanCapUser swapVal,
                        Lnd.outgoingChanId =
                          extId
                      }
                )
      eitherM
        ( \e -> do
            Psql.transactionUndo
            $(logTM) ErrorS . logStr $
              "SettleSwap procedure failed: " <> inspect e
        )
        ( \x -> do
            SwapIntoLn.updateSucceededSql swapKey x
            SwapUtxo.updateSpentChanSwappedSql swapKey
        )
        . lift
        . runExceptT
        $ do
          catchE (sendPaymentT . lnChanExtId $ entityVal chanEnt)
            . const
            . catchE (sendPaymentT Nothing)
            . const
            $ do
              inv <-
                withLndT
                  LndKatip.decodePayReq
                  ($ payReq)
              pay <-
                withLndT
                  LndKatip.trackPaymentSync
                  ( $
                      TrackPayment.TrackPaymentRequest
                        { TrackPayment.paymentHash =
                            PayReq.paymentHash inv,
                          TrackPayment.noInflightUpdates =
                            False
                        }
                  )
              if Payment.state pay == Payment.SUCCEEDED
                then
                  pure $
                    Payment.paymentPreimage pay
                else
                  throwE . FailureInternal $
                    "Wrong payment "
                      <> inspectPlain pay
                      <> " for swap "
                      <> inspectPlain swapEnt
                      <> " and user "
                      <> inspectPlain userEnt
                      <> " and chan "
                      <> inspectPlain chanEnt
  whenLeft res $
    $(logTM) ErrorS
      . logStr
      . ("Swap failed due to wrong status " <>)
      . inspect
