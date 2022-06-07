{-# LANGUAGE TypeApplications #-}

module IntegrationSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import hiding (setGrpcCtx, setGrpcCtxT)
import qualified BtcLsp.Thread.Main as Main
import qualified LndClient as Lnd
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.ListChannels as ListChannels
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.Data.SendCoins as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.LndTest as LndTest
import qualified LndClient.RPC.Silent as Lnd
import qualified Proto.BtcLsp.Data.LowLevel_Fields as SwapIntoLn
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Test.Hspec
import TestAppM
import TestOrphan ()

spec :: Spec
spec = do
  itEnv @'LndLsp "Server SwapIntoLn" $ do
    -- Let app spawn
    Main.waitForSync
    sleep300ms
    gcEnv <- getGCEnv
    res0 <- runExceptT $ do
      fundInv <-
        from . Lnd.paymentRequest
          <$> withLndTestT
            LndAlice
            Lnd.addInvoice
            ( $
                Lnd.AddInvoiceRequest
                  { Lnd.valueMsat = MSat 0,
                    Lnd.memo = Nothing,
                    Lnd.expiry =
                      Just
                        . Lnd.Seconds
                        $ 7 * 24 * 3600
                  }
            )
      refundAddr <-
        from
          <$> withLndTestT
            LndAlice
            Lnd.newAddress
            ( $
                Lnd.NewAddressRequest
                  { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
                    Lnd.account = Nothing
                  }
            )
      Client.swapIntoLnT
        gcEnv
          { gcEnvCompressMode = Compressed
          }
        =<< setGrpcCtxT
          LndAlice
          ( defMessage
              & SwapIntoLn.fundLnInvoice
                .~ from @(LnInvoice 'Fund) fundInv
              & SwapIntoLn.refundOnChainAddress
                .~ from @(OnChainAddress 'Refund) refundAddr
          )
    liftIO $
      res0
        `shouldSatisfy` ( \case
                            Left {} ->
                              False
                            Right msg ->
                              isJust $
                                msg ^. SwapIntoLn.maybe'success
                        )

    res1 <- runExceptT $ do
      resp <- except res0
      let fundAddr =
            resp
              ^. ( SwapIntoLn.success
                     . SwapIntoLn.fundOnChainAddress
                     . SwapIntoLn.val
                     . SwapIntoLn.val
                 )
      void $
        withLndTestT
          LndAlice
          Lnd.sendCoins
          ( \h ->
              h (Lnd.SendCoinsRequest fundAddr (MSat 200000000))
          )
      lift $
        LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
      lift $ mine 10 LndLsp
      sleep10s
      lift Main.waitForSync
      lift $ mine 10 LndLsp
      sleep10s
      alicePub <- getPubKeyT LndAlice
      withLndT
        Lnd.listChannels
        ( $
            ListChannels.ListChannelsRequest
              { ListChannels.activeOnly = True,
                ListChannels.inactiveOnly = False,
                ListChannels.publicOnly = False,
                ListChannels.privateOnly = False,
                ListChannels.peer = Just alicePub
              }
        )
    liftIO $
      res1
        `shouldSatisfy` ( \case
                            Right [_] -> True
                            _ -> False
                        )
