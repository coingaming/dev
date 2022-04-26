module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import
import BtcLsp.Storage.Model.SwapIntoLn (updateFundedSql)
import BtcLsp.Storage.Model.SwapUtxo (getUtxosBySwapIdSql)
import BtcLsp.Thread.BlockScanner (trySat2MSat)
import qualified BtcLsp.Thread.BlockScanner as BSC
import qualified BtcLsp.Thread.Refunder as RF
import Data.Either.Extra (mapLeft)
import qualified Data.Vector as V
import LndClient (txIdParser)
import LndClient.LndTest (mine, liftLndResult)
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.Types as Btc
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestWithLndLsp
import qualified Data.Set as S
import Data.List (intersect)
import Universum (show)

scanner :: Env m => m ()
scanner = BSC.apply [RF.apply]

uniq :: Ord a => [a] -> [a]
uniq x = S.toList $ S.fromList x

allIn :: Eq a => [a] -> [a] -> Bool
allIn ax bx = intersect ax bx == ax

refundSucceded :: Entity SwapIntoLn -> [TxId 'Funding] -> TestAppM 'LndLsp IO (Bool, [TxId 'Funding])
refundSucceded swp preTrs = do
  res <- runExceptT $ do
    utxos <- lift . runSql $ getUtxosBySwapIdSql (entityKey swp)
    refIds <- sequence $ (except . maybeToRight (FailureInternal "")) . swapUtxoRefundTxId . entityVal <$> utxos
    trsInBlock' <-
      fmap (txIdParser . Btc.unTransactionID . Btc.decTxId) . V.toList . Btc.vSubTransactions <$> getLatestBlock
    trsInBlock <- liftLndResult $ sequence trsInBlock'
    let foundTrs = (from <$> trsInBlock) <> preTrs
    let allRefundTxsOnChain = allIn (uniq refIds) foundTrs
    let utxosMakedRefunded = not $ null utxos && all ((== SwapUtxoRefunded) . swapUtxoStatus . entityVal) utxos
    pure (allRefundTxsOnChain && utxosMakedRefunded, foundTrs)
  pure $ fromRight (False, preTrs) res


spec :: Spec
spec =
  itEnv "Refunder Spec" $ do
    eSwp <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      amtMSat <- except $ mapLeft (const $ FailureInternal "Failed to convert msat to sat") $ trySat2MSat amt
      mCap <- lift $ newSwapCapM (from amtMSat)
      cap <- except $ maybeToRight (FailureInternal "failed to get cap") mCap
      swp <- createDummySwap "refunder test"
      void $ lift $ runSql $ updateFundedSql (entityKey swp) cap
      _trId <- withBtcT Btc.sendToAddress (\h -> h (from . swapIntoLnFundAddress . entityVal $ swp) amt Nothing Nothing)
      void putLatestBlockToDB
      lift $ mine 4 LndLsp
      pure swp
    case eSwp of
      Right swp ->
        withSpawnLink scanner $ const $ do
          x <- waitCond 10 (refundSucceded swp) []
          liftIO $ shouldBe x True
      Left e -> liftIO $ expectationFailure $ show e
