module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
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
spec =
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
