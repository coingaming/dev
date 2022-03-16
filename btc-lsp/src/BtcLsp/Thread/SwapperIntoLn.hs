{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.SwapperIntoLn
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
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
apply = do
  ePeerList <- withLnd LndSilent.listPeers id
  whenLeft ePeerList $
    $(logTM) ErrorS
      . logStr
      . ("ListPeers procedure failed: " <>)
      . inspect
  let peerSet =
        Set.fromList $
          Peer.pubKey <$> fromRight [] ePeerList
  swaps <- SwapIntoLn.getSwapsToSettle
  tasks <-
    mapM
      ( spawnLink
          . settleSwap
      )
      $ filter
        ( \x ->
            Set.member
              (userNodePubKey . entityVal $ snd x)
              peerSet
        )
        swaps
  mapM_ (liftIO . wait) tasks
  sleep $ MicroSecondsDelay 500000
  apply

settleSwap :: (Env m) => (Entity SwapIntoLn, Entity User) -> m ()
settleSwap (swapEnt, userEnt) = do
  res <- runExceptT $ do
    pre <-
      catchE sendPaymentT . const $ do
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

    lift $
      SwapIntoLn.updateSettled (entityKey swapEnt) pre
  whenLeft res $
    $(logTM) ErrorS . logStr
      . ("SettleSwap procedure failed: " <>)
      . inspect
  where
    swap =
      entityVal swapEnt
    payReq =
      from $
        swapIntoLnFundInvoice swap
    sendPaymentT =
      SendPayment.paymentPreimage
        <$> withLndT
          LndKatip.sendPayment
          ( $
              Lnd.SendPaymentRequest
                { Lnd.paymentRequest = payReq,
                  Lnd.amt = from $ swapIntoLnChanCapUser swap
                }
          )
