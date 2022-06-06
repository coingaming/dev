{-# LANGUAGE TypeApplications #-}

module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import hiding (setGrpcCtx, setGrpcCtxT)
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified LndClient as Lnd
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
import TestAppM
import TestOrphan ()

spec :: Spec
spec = forM_ [Compressed, Uncompressed] $ \compressMode -> do
  itMainT @'LndLsp "GetCfg" $ do
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
    gcEnv <- lift getGCEnv
    pub <- getPubKeyT LndLsp
    res0 <-
      Client.getCfgT
        gcEnv
          { gcEnvCompressMode = compressMode
          }
        =<< setGrpcCtxT LndAlice defMessage
    liftIO $
      (res0 ^. GetCfg.success)
        `shouldBe` ( defMessage
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
  itMainT @'LndLsp "Server SwapIntoLn" $ do
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
      mine 1 LndLsp
        >> sleep5s
        >> LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
    swapsToChan <-
      lift $
        runSql SwapIntoLn.getSwapsWaitingChanSql
    liftIO $
      swapsToChan
        `shouldSatisfy` ((== 1) . length)
    lift $
      mine 1 LndLsp
        >> sleep5s
        >> LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
    alicePub <- getPubKeyT LndAlice
    lndChans <-
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
      lndChans
        `shouldSatisfy` ((== 1) . length)
