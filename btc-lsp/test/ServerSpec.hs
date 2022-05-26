{-# LANGUAGE TypeApplications #-}

module ServerSpec
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
import LndClient.LndTest (mine)
import qualified LndClient.LndTest as LndTest
import qualified LndClient.RPC.Silent as Lnd
import qualified Network.Bitcoin as Btc
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Data.LowLevel_Fields as LowLevel
import qualified Proto.BtcLsp.Data.LowLevel_Fields as SwapIntoLn
import qualified Proto.BtcLsp.Method.GetCfg_Fields as GetCfg
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = forM_ [Compressed, Uncompressed] $ \compressMode -> do
  itEnv "GetCfg" $
    withSpawnLink Main.apply . const $ do
      let minAmt :: Proto.LocalBalance =
            defMessage
              & Proto.val
                .~ ( defMessage
                       & LowLevel.val .~ 12000000
                   )
      let maxAmt :: Proto.LocalBalance =
            defMessage
              & Proto.val
                .~ ( defMessage
                       & LowLevel.val .~ 10000000000
                   )
      -- Let app spawn
      Main.waitForSync
      sleep $ MicroSecondsDelay 500000
      --
      -- TODO : implement withGCEnv!!!
      --
      gcEnv <- getGCEnv
      pub <- getLspPubKey
      res0 <-
        runExceptT $
          Client.getCfgT
            gcEnv
              { gcEnvCompressMode = compressMode
              }
            =<< setGrpcCtxT LndAlice defMessage
      liftIO $
        (^. GetCfg.success) <$> res0
          `shouldBe` Right
            ( defMessage
                & GetCfg.lspLnNodes
                  .~ [ defMessage
                         & Proto.pubKey
                           .~ from pub
                         & Proto.host
                           .~ ( defMessage
                                  & Proto.val .~ "127.0.0.1"
                              )
                         & Proto.port
                           .~ ( defMessage
                                  & Proto.val .~ 9736
                              )
                     ]
                & GetCfg.swapIntoLnMinAmt .~ minAmt
                & GetCfg.swapIntoLnMaxAmt .~ maxAmt
                & GetCfg.swapFromLnMinAmt .~ minAmt
                & GetCfg.swapFromLnMaxAmt .~ maxAmt
                & GetCfg.swapLnFeeRate
                  .~ ( defMessage
                         & Proto.val
                           .~ ( defMessage
                                  & LowLevel.numerator .~ 1
                                  & LowLevel.denominator .~ 250
                              )
                     )
                & GetCfg.swapLnMinFee
                  .~ ( defMessage
                         & Proto.val
                           .~ ( defMessage
                                  & LowLevel.val .~ 2000000
                              )
                     )
            )
  itEnv "Server SwapIntoLn" $ do
    res <- withSpawnLink Main.apply . const . runExceptT $ do
      lift Main.waitForSync
      -- Let app spawn
      sleep $ MicroSecondsDelay 500000
      gcEnv <- lift getGCEnv
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
      res0 <-
        Client.swapIntoLnT
          gcEnv
            { gcEnvCompressMode = compressMode
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
          `shouldSatisfy` ( \msg ->
                              isJust $
                                msg ^. SwapIntoLn.maybe'success
                          )
      let fundAddr =
            res0
              ^. ( SwapIntoLn.success
                     . SwapIntoLn.fundOnChainAddress
                     . SwapIntoLn.val
                     . SwapIntoLn.val
                 )
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h fundAddr 0.01 Nothing Nothing)
      lift $
        LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
      sleep $ MicroSecondsDelay 5000000
      lift $ mine 6 LndLsp
      sleep $ MicroSecondsDelay 5000000
      lift $ mine 6 LndLsp
      res1 <-
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
          `shouldSatisfy` ((== 1) . length)
    liftIO $
      res `shouldSatisfy` isRight
