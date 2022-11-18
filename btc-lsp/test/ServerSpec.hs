{-# LANGUAGE TypeApplications #-}

module ServerSpec
  ( spec,
  )
where

import qualified BtcLsp.Grpc.Client.HighLevel as Client
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import hiding (setGrpcCtx, setGrpcCtxT)
import qualified BtcLsp.Storage.Model.LnChan as L
import qualified BtcLsp.Storage.Model.SwapIntoLn as S
import qualified BtcLsp.Storage.Model.SwapUtxo as SU
import qualified LndClient as Lnd
import qualified LndClient.Data.Channel as Lnd
import qualified LndClient.Data.ListChannels as ListChannels
import LndClient.LndTest (lazyConnectNodes, mine)
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
import TestHelpers
import TestOrphan ()

getChannels :: Env m => Lnd.NodePubKey -> ExceptT Failure m [Lnd.Channel]
getChannels pub =
  withLndT
    Lnd.listChannels
    ( $
        ListChannels.ListChannelsRequest
          { ListChannels.activeOnly = True,
            ListChannels.inactiveOnly = False,
            ListChannels.publicOnly = False,
            ListChannels.privateOnly = False,
            ListChannels.peer = Just pub
          }
    )

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
                                  .~ toProto pub
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
    lift $ mine 200 LndLsp
    gcEnv <- lift getGCEnv
    refundAddr <- from <$> genAddress LndAlice
    res0 <-
      Client.swapIntoLnT
        gcEnv
          { gcEnvCompressMode = compressMode
          }
        =<< setGrpcCtxT
          LndAlice
          ( defMessage
              & SwapIntoLn.refundOnChainAddress
                .~ toProto @(OnChainAddress 'Refund) refundAddr
          )

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
    alicePub <- getPubKeyT LndAlice
    void $ withBtcT Btc.sendToAddress (\h -> h fundAddr 0.01 Nothing Nothing)
    lift $ mine 5 LndLsp >> sleep1s >> lazyConnectNodes (Proxy :: Proxy TestOwner)
    checksPassed <-
      lift $
        waitCond
          10
          ( \_ -> do
              mine 5 LndLsp
              eLndChans <- runExceptT $ getChannels alicePub
              mswp <- runSql $ S.getByFundAddressSql (unsafeNewOnChainAddress fundAddr)
              case (mswp, eLndChans) of
                (Just swp, Right lndChans) -> do
                  let swapInDbSuccess = SwapSucceeded == swapIntoLnStatus (entityVal swp)
                  utxos <- runSql $ SU.getUtxosBySwapIdSql $ entityKey swp
                  let allUtxosMarkedAsUsed = all (\u -> swapUtxoStatus (entityVal u) == SwapUtxoSpentChanSwapped) utxos
                  let expectedRemoteBalance = swapIntoLnChanCapUser $ entityVal swp
                  dbChans <- runSql $ L.getBySwapIdSql $ entityKey swp
                  let chanExistInDb = length dbChans == 1
                  let openedChanWithRightCap = isJust $ find (\c -> Lnd.remoteBalance c == from expectedRemoteBalance) lndChans
                  pure (swapInDbSuccess && allUtxosMarkedAsUsed && openedChanWithRightCap && chanExistInDb, ())
                _ -> pure (False, ())
          )
          ()
    liftIO $ do
      shouldBe (fst checksPassed) True
