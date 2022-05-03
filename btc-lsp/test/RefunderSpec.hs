{-# LANGUAGE TypeApplications #-}

module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
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
import Universum (show)

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
    putStrLn $ inspect utxos
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
          not $
            null utxos
              && all
                ( (== SwapUtxoRefunded)
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
spec =
  itEnv "Refunder Spec" $
    runExceptT
      ( do
          amt <-
            lift getSwapIntoLnMinAmt
          swp <-
            createDummySwap "refunder test"
              . Just
              =<< getFutureTime (Lnd.Seconds 800)
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
          pure swp
      )
      >>= \case
        Right swp ->
          withSpawnLink Main.apply . const $ do
            x <- waitCond 10 (refundSucceded swp) []
            liftIO $ shouldBe x True
        Left e ->
          liftIO
            . expectationFailure
            $ show e
