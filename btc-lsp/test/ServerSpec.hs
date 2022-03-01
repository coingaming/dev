{-# LANGUAGE TypeApplications #-}

module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Cfg as Cfg
import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Thread.Main as Main
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.ListChannels as ListChannels
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.LndTest as LndTest
import qualified LndClient.RPC.Katip as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Data.LowLevel_Fields as LowLevel
import qualified Proto.BtcLsp.Method.GetCfg_Fields as GetCfg
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = forM_ [Compressed, Uncompressed] $ \compressMode -> do
  itEnv "GetCfg" $
    withSpawnLink Main.apply . const $ do
      -- Let app spawn
      sleep $ MicroSecondsDelay 500000
      --
      -- TODO : implement withGCEnv!!!
      --
      gsEnv <- getGsEnv
      gcEnv <- getGCEnv
      pub <- getLspPubKey
      res0 <-
        Client.getCfg
          gsEnv
          (gcEnv {gcEnvCompressMode = compressMode})
          =<< setGrpcCtx defMessage
      let minAmt :: Proto.LocalBalance =
            defMessage
              & Proto.val
                .~ ( defMessage
                       & LowLevel.val .~ 10000000
                   )
      let maxAmt :: Proto.LocalBalance =
            defMessage
              & Proto.val
                .~ ( defMessage
                       & LowLevel.val .~ 10000000000
                   )
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
                                  & Proto.val .~ 10010
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
  itEnv "SwapIntoLn" $
    withSpawnLink Main.apply . const $ do
      -- Let app spawn
      sleep $ MicroSecondsDelay 500000
      --
      -- TODO : implement withGCEnv!!!
      --
      gsEnv <- getGsEnv
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
        --
        -- TODO : remove gsEnv argument, add own signer
        -- into gcEnv. Without proper signer, this test
        -- is meaningless, because LSP can not recognize
        -- itself as a peer to open channel. Peer and
        -- signer should be Alice node!!!
        --
        Client.swapIntoLnT
          gsEnv
          (gcEnv {gcEnvCompressMode = compressMode})
          =<< setGrpcCtxT
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
        lift $ LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
        swapEnt <- SwapIntoLn.getLatestSwapT
        let amt = Cfg.swapLnMaxAmt
        lift $
          SwapIntoLn.updateFunded
            (swapIntoLnFundAddress $ entityVal swapEnt)
            amt
            (Cfg.newChanCapLsp amt)
            (Cfg.newSwapIntoLnFee amt)
        -- Let channel be opened
        sleep $ MicroSecondsDelay 5000000
        lift $ mine 6 LndLsp
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
                              Left {} ->
                                False
                              Right {} ->
                                True
                          )
