{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TemplateHaskell #-}
module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import hiding (setGrpcCtxT)
import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import Data.List (intersect)
import qualified Data.Vector as V
import LndClient (txIdParser)
import qualified LndClient as Lnd
import qualified LndClient.Data.SendCoins as SendCoins
import LndClient.LndTest (liftLndResult, mine)
import qualified LndClient.RPC.Silent as Lnd
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Grpc.Client.HighLevel as Client
import qualified LndClient.Data.AddInvoice as Lnd
--import qualified LndClient.Data.ListChannels as ListChannels
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.LndTest as LndTest
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import BtcLsp.Grpc.Client.LowLevel
import qualified Proto.BtcLsp.Data.LowLevel_Fields as SwapIntoLn
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Universum

allIn :: Eq a => [a] -> [a] -> Bool
allIn ax bx =
  intersect ax bx == ax

refundSucceded ::
  Entity SwapIntoLn ->
  [TxId 'Funding] ->
  TestAppM 'LndLsp IO (Bool, [TxId 'Funding])
refundSucceded swp preTrs = do
  res <- runExceptT $ do
    utxos <-
      lift
        . runSql
        $ getUtxosBySwapIdSql (entityKey swp)
    refIds <-
      sequence $
        ( except
            . maybeToRight
              (FailureInternal "missing txid")
        )
          . swapUtxoRefundTxId
          . entityVal
          <$> utxos
    trsInBlock' <-
      fmap (txIdParser . Btc.unTransactionID . Btc.decTxId)
        . V.toList
        . Btc.vSubTransactions
        <$> getLatestBlock
    trsInBlock <-
      liftLndResult $ sequence trsInBlock'
    let foundTrs = (from <$> trsInBlock) <> preTrs
    let allRefundTxsOnChain = allIn (nubOrd refIds) foundTrs
    let utxosMakedRefunded =
          notNull utxos
            && all
              ( (== SwapUtxoSpentRefund)
                  . swapUtxoStatus
                  . entityVal
              )
              utxos
    pure
      ( allRefundTxsOnChain && utxosMakedRefunded,
        foundTrs
      )
  pure $
    fromRight (False, preTrs) res

spec :: Spec
spec = do
  itMainT "Refunder Spec" $ do
    amt <-
      lift getSwapIntoLnMinAmt
    swp <-
      createDummySwap . Just
        =<< getFutureTime (Lnd.Seconds 5)
    -- Let Expirer to expiry the swap
    sleep $ MicroSecondsDelay 1000000
    void $
      withLndT
        Lnd.sendCoins
        ( $
            SendCoins.SendCoinsRequest
              { SendCoins.addr =
                  from
                    . swapIntoLnFundAddress
                    . entityVal
                    $ swp,
                SendCoins.amount =
                  from amt
              }
        )
    lift $ mine 1 LndLsp
    -- Let Refunder to refund UTXO
    sleep $ MicroSecondsDelay 1000000
    res <- lift $ waitCond 10 (refundSucceded swp) []
    liftIO $ res `shouldSatisfy` fst
  itMainT "Refunder + reorg Spec" $ do
    void $ withBtcT Btc.setNetworkActive ($ False)
    _ <- BlockScanner.scan

    void $ withBtc2T Btc.generate (\h -> h 30 Nothing)

    amt <-
      lift getSwapIntoLnMinAmt
    swp <-
      createDummySwap . Just
        =<< getFutureTime (Lnd.Seconds 5)
    -- Let Expirer to expiry the swap
    sleep $ MicroSecondsDelay 1000000
    void $
      withLndT
        Lnd.sendCoins
        ( $
            SendCoins.SendCoinsRequest
              { SendCoins.addr =
                  from
                    . swapIntoLnFundAddress
                    . entityVal
                    $ swp,
                SendCoins.amount =
                  from amt
              }
        )
    lift $ mine 1 LndLsp
    -- Let Refunder to refund UTXO
    sleep $ MicroSecondsDelay 1000000
    let swpId = entityKey swp
    res <- lift $ waitCond 10 (refundSucceded swp) []
    utxos <- lift $ runSql $ getUtxosBySwapIdSql swpId
    case listToMaybe utxos of
      Just utxo -> do
        liftIO $ swapUtxoStatus (entityVal utxo) `shouldBe` SwapUtxoSpentRefund
      Nothing -> error "There should be one Utxo for Swap"

    void $ withBtcT Btc.setNetworkActive ($ True)
    void $ ExceptT waitTillNodesSynchronized

    lift $ mine 20 LndLsp
    utxos2 <- lift $ runSql $ getUtxosBySwapIdSql swpId
    case listToMaybe utxos2 of
      Just utxo2 -> do
        liftIO $ swapUtxoStatus (entityVal utxo2) `shouldBe` SwapUtxoOrphan
      Nothing -> error "There should be one Utxo for Swap"
    liftIO $ res `shouldSatisfy` fst
  itMainT "Refunder 2" $ do
    void $ withBtcT Btc.setNetworkActive ($ False)
    _ <- BlockScanner.scan

    void $ withBtc2T Btc.generate (\h -> h 30 Nothing)

    amt <-
      lift getSwapIntoLnMinAmt
    swp <-
      createDummySwap . Just
        =<< getFutureTime (Lnd.Seconds 5)
    -- Let Expirer to expiry the swap
    sleep $ MicroSecondsDelay 1000000
    void $
      withLndT
        Lnd.sendCoins
        ( $
            SendCoins.SendCoinsRequest
              { SendCoins.addr =
                  from
                    . swapIntoLnFundAddress
                    . entityVal
                    $ swp,
                SendCoins.amount =
                  from amt
              }
        )
    -- Let Refunder to refund UTXO
    _res <- lift $ waitCond 10 (refundSucceded swp) []

    void $ withBtcT Btc.setNetworkActive ($ True)
    void $ ExceptT waitTillNodesSynchronized
  focus $ itMainT @'LndLsp "Server SwapIntoLn" $ do
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
          { gcEnvCompressMode = Uncompressed
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
        >> sleep (MicroSecondsDelay 5000000)
        >> LndTest.lazyConnectNodes (Proxy :: Proxy TestOwner)
    swapsToChan <-
      lift $
        runSql SwapIntoLn.getSwapsWaitingChanSql
    liftIO $
      swapsToChan
        `shouldSatisfy` ((== 1) . length)

    $(logTM) ErrorS "========================================"
    $(logTM) ErrorS "========================================"
    $(logTM) ErrorS "========================================"
    $(logTM) ErrorS (Universum.show swapsToChan)

    return ()
waitTillNodesSynchronized :: (MonadReader (TestEnv o) m, Env m) => m (Either Failure ())
waitTillNodesSynchronized = runExceptT $ do
  sleep (MicroSecondsDelay 1000000)
  blockCount1 <- withBtcT Btc.getBlockCount id
  blockCount2 <- withBtc2T Btc.getBlockCount id
  if blockCount1 == blockCount2
    then do
      blockHash1 <- withBtcT Btc.getBlockHash ($ blockCount1)
      blockHash2 <- withBtc2T Btc.getBlockHash ($ blockCount2)
      if blockHash1 == blockHash2
        then return ()
        else ExceptT waitTillNodesSynchronized
    else ExceptT waitTillNodesSynchronized




