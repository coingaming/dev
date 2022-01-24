{-# LANGUAGE TypeApplications #-}

module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Thread.Server as Server
--import qualified LndClient.Data.PayReq as Lnd

import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Test.Hspec
import TestOrphan ()
import TestWithPaymentsPartner

spec :: Spec
spec =
  itEnv "SwapIntoLn" $
    withSpawnLink Server.apply . const $ do
      -- Let gRPC server spawn
      sleep $ MicroSecondsDelay 100
      --
      -- TODO : implement withGCEnv!!!
      --
      gcEnv <- getGCEnv
      res <- runExceptT $ do
        fundInv <-
          from . Lnd.paymentRequest
            <$> withLndT
              Lnd.addInvoice
              ( $
                  Lnd.AddInvoiceRequest
                    { Lnd.valueMsat = MSat 1000000,
                      Lnd.memo = Nothing,
                      Lnd.expiry = Nothing
                    }
              )
        refundAddr <-
          from
            <$> withLndT
              Lnd.newAddress
              --
              -- TODO : maybe pass LndEnv as the last argument
              -- to the methods (not the first like right now)
              -- to avoid this style of withLndT?
              --
              ( $
                  Lnd.NewAddressRequest
                    { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
                      Lnd.account = Nothing
                    }
              )
        Client.swapIntoLnT
          gcEnv
          =<< setGrpcCtxT
            ( defMessage
                & SwapIntoLn.fundLnInvoice
                  .~ from @(LnInvoice 'Fund) fundInv
                & SwapIntoLn.refundOnChainAddress
                  .~ from @(OnChainAddress 'Refund) refundAddr
            )
      liftIO $
        res
          `shouldSatisfy` ( \case
                              Left {} ->
                                False
                              Right msg ->
                                isJust $
                                  msg ^. SwapIntoLn.maybe'success
                          )
