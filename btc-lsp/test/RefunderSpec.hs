module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified BtcLsp.Thread.Main as Main
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
  itEnvT "Refunder Spec" $ do
    amt <-
      lift getSwapIntoLnMinAmt
    swp <-
      createDummySwap "refunder test"
        . Just
        =<< getFutureTime (Lnd.Seconds 5)
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
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    lift . withSpawnLink Main.apply . const $ do
      x <- waitCond 10 (refundSucceded swp) []
      liftIO $ x `shouldBe` True
  focus $
    itEnvT "Refunder + reorg Spec" $ do
      void $ withBtcT Btc.setNetworkActive ($ False)
      _ <- BlockScanner.scan

      void $ withBtc2T Btc.generate (\h -> h 30 Nothing)
      amt <-
        lift getSwapIntoLnMinAmt
      swp <-
        createDummySwap "refunder test"
          . Just
          =<< getFutureTime (Lnd.Seconds 5)
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
      void putLatestBlockToDB
      lift $ mine 4 LndLsp
      lift . withSpawnLink Main.apply . const $ do
        let swpId = entityKey swp
        x <- waitCond 10 (refundSucceded swp) []
        utxos <- runSql $ getUtxosBySwapIdSql swpId
        case listToMaybe utxos of
          Just utxo -> do
            liftIO $ swapUtxoStatus (entityVal utxo) `shouldBe` SwapUtxoSpentRefund
          Nothing -> error "There should be one Utxo for Swap"


        void $ withBtc Btc.setNetworkActive ($ True)
        void waitTillNodesSynchronized

        mine 10 LndLsp
        utxos2 <- runSql $ getUtxosBySwapIdSql swpId
        case listToMaybe utxos2 of
          Just utxo2 -> do
            liftIO $ swapUtxoStatus (entityVal utxo2) `shouldBe` SwapUtxoOrphan
          Nothing -> error "There should be one Utxo for Swap"

        liftIO $ x `shouldBe` True

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
