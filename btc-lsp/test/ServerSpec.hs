{-# LANGUAGE TypeApplications #-}

module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Thread.Server as Server
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
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
    withSpawnLink Server.apply . const $ do
      -- Let gRPC server spawn
      sleep $ MicroSecondsDelay 100
      --
      -- TODO : implement withGCEnv!!!
      --
      gsEnv <- getGsEnv
      gcEnv <- getGCEnv
      pub <- getLspPubKey
      res <-
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
        (^. GetCfg.success) <$> res
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
    withSpawnLink Server.apply . const $ do
      -- Let gRPC server spawn
      sleep $ MicroSecondsDelay 100
      --
      -- TODO : implement withGCEnv!!!
      --
      gsEnv <- getGsEnv
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
      -- TODO : do exact match!!!
      --
      liftIO $
        res
          `shouldSatisfy` ( \case
                              Left {} ->
                                False
                              Right msg ->
                                isJust $
                                  msg ^. SwapIntoLn.maybe'success
                          )
