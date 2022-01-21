{-# LANGUAGE TypeApplications #-}

module BtcLsp.Grpc.Server.HighLevel
  ( swapIntoLn,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.Data.PayReq as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn

swapIntoLn ::
  ( Env m
  ) =>
  Entity User ->
  SwapIntoLn.Request ->
  m SwapIntoLn.Response
swapIntoLn userEnt req = do
  res <- runExceptT $ do
    fundInv <-
      fromReqT $
        req ^. SwapIntoLn.maybe'fundLnInvoice
    refundAddr <-
      fromReqT $
        req ^. SwapIntoLn.maybe'refundOnChainAddress
    fundAddr <-
      from
        <$> withLndT
          Lnd.newAddress
          ( $
              Lnd.NewAddressRequest
                { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
                  Lnd.account = Nothing
                }
          )
    fundInvLnd <-
      withLndT
        Lnd.decodePayReq
        ($ from fundInv)
    expAt <-
      lift
        . getFutureTime
        $ Lnd.expiry fundInvLnd
    lift $
      SwapIntoLn.create
        userEnt
        fundInv
        fundAddr
        refundAddr
        (from $ Lnd.numMsat fundInvLnd)
        expAt
  pure $ case res of
    Left e ->
      failResE e
    Right (Entity _ swap) ->
      defMessage
        & SwapIntoLn.success
          .~ ( defMessage
                 & SwapIntoLn.fundOnChainAddress
                   .~ from (swapIntoLnFundAddress swap)
                 & SwapIntoLn.fundMoney
                   .~ from @MSat
                     ( from (swapIntoLnChanCapUser swap)
                         + from (swapIntoLnFeeLsp swap)
                     )
             )
