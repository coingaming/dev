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
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  itEnv "Server SwapIntoLn" $ do
    -- Let app spawn
    Main.waitForSync
    sleep $ MicroSecondsDelay 500000
    --
    -- TODO : implement withGCEnv!!!
    --
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
                    Lnd.expiry = Nothing
                  }
            )
      refundAddr <-
        from
          <$> withLndTestT
            LndAlice
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
    --
    -- TODO : do more precise match!!!
    --
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
      void $ withLndTestT LndAlice Lnd.sendCoins (\h -> h (Lnd.SendCoinsRequest fundAddr (MSat 200000000)))
      lift $
        LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
      lift $ mine 10 LndLsp
      sleep $ MicroSecondsDelay 10000000
      lift Main.waitForSync
      lift $ mine 10 LndLsp
      sleep $ MicroSecondsDelay 10000000
      withLndT
        Lnd.listChannels
        ( $
            ListChannels.ListChannelsRequest
              { ListChannels.activeOnly = True,
                ListChannels.inactiveOnly = False,
                ListChannels.publicOnly = False,
                ListChannels.privateOnly = False,
                --
                -- TODO : add peer
                --
                ListChannels.peer = Nothing
              }
        )
    liftIO $
      res1
        `shouldSatisfy` ( \case
                            Right [_] ->
                              True
                            _ ->
                              False
                        )
