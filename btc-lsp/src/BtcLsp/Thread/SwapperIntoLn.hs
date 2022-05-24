{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.SwapperIntoLn
  ( apply,
  )
where

import BtcLsp.Import
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
    swapsToSettle <-
      runSql SwapIntoLn.getSwapsWaitingLnFundSql
    tasks <-
      mapM
        ( spawnLink
            . uncurry3 settleSwap
        )
        $ filter
          ( \(_, usr, _) ->
              Set.member
                (userNodePubKey $ entityVal usr)
                peerSet
          )
          swapsToSettle
    mapM_ (liftIO . wait) tasks
    sleep $ MicroSecondsDelay 500000

settleSwap ::
  ( Env m
  ) =>
  Entity SwapIntoLn ->
  Entity User ->
  Entity LnChan ->
  m ()
settleSwap swapEnt@(Entity swapKey _) userEnt chanEnt =
  runSql . SwapIntoLn.withLockedExtantRowSql swapKey $ \swapVal -> do
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
      ( $(logTM) ErrorS . logStr
          . ("SettleSwap procedure failed: " <>)
          . inspect
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
