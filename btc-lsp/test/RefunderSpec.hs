module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import hiding (setGrpcCtxT)
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
import TestAppM
import TestHelpers
import TestOrphan ()

--import qualified BtcLsp.Thread.BlockScanner as BlockScanner
--import qualified Data.ByteString.Lazy as L
--import qualified Data.Digest.Pure.SHA as SHA
--  ( bytestringDigest,
--    sha256,
--  )
--import qualified LndClient.Data.LeaseOutput as LO
--import qualified LndClient.Data.ListLeases as LL
--import qualified LndClient.Data.OutPoint as OP
--import LndClient.RPC.Katip
--import Universum

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
              (FailureInt $ FailurePrivate "missing txid")
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
    sleep1s -- Let Expirer to expiry the swap
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
    sleep1s -- Let Refunder to refund UTXO
    res <- lift $ waitCond 10 (refundSucceded swp) []
    liftIO $ res `shouldSatisfy` fst

--  ============================================================================
--  Following test is break LeaseOutput lnd method (LeaseOutput Breaks specifies how)
--  ============================================================================
--  itMainT "Refunder + reorg Spec" $ do
--    void $ withBtcT Btc.setNetworkActive ($ False)
--    _ <- BlockScanner.scan
--
--    void $ withBtc2T Btc.generate (\h -> h 5 Nothing)
--
--    amt <-
--      lift getSwapIntoLnMinAmt
--    swp <-
--      createDummySwap . Just
--        =<< getFutureTime (Lnd.Seconds 5)
--    -- Let Expirer to expiry the swap
--    sleep1s
--    void $
--      withLndT
--        Lnd.sendCoins
--        ( $
--            SendCoins.SendCoinsRequest
--              { SendCoins.addr =
--                  from
--                    . swapIntoLnFundAddress
--                    . entityVal
--                    $ swp,
--                SendCoins.amount =
--                  from amt
--              }
--        )
--    lift $ mine 1 LndLsp
--    -- Let Refunder to refund UTXO
--    sleep1s
--    let swpId = entityKey swp
--    res <- lift $ waitCond 10 (refundSucceded swp) []
--    utxos <- lift $ runSql $ getUtxosBySwapIdSql swpId
--    case listToMaybe utxos of
--      Just utxo -> do
--        liftIO $ swapUtxoStatus (entityVal utxo) `shouldBe` SwapUtxoSpentRefund
--      Nothing -> error "There should be one Utxo for Swap"
--
--    void $ withBtcT Btc.setNetworkActive ($ True)
--    void $ ExceptT $ waitTillNodesSynchronized 100
--
--    lift $ mine 20 LndLsp
--    utxos2 <- lift $ runSql $ getUtxosBySwapIdSql swpId
--    case listToMaybe utxos2 of
--      Just utxo2 -> do
--        liftIO $ swapUtxoStatus (entityVal utxo2) `shouldBe` SwapUtxoOrphan
--      Nothing -> error "There should be one Utxo for Swap"
--    liftIO $ res `shouldSatisfy` fst
--  itMainT @'LndLsp "LeaseOutput Breaks" $ do
--    void $ withBtcT Btc.setNetworkActive ($ False)
--    void $ withBtc2T Btc.generate (\h -> h 6 Nothing)
--    lift $ mine 5 LndLsp
--    void $ withBtcT Btc.setNetworkActive ($ True)
--    void $ ExceptT $ waitTillNodesSynchronized 100
--    sleep1s
--    bHeight <- withBtc2T Btc.getBlockCount id
--    hash <- withBtc2T Btc.getBlockHash ($ bHeight)
--    blk <- withBtc2T Btc.getBlockVerbose ($ hash)
--    let trs = case listToMaybe $ toList $ Btc.vSubTransactions blk of
--          Just t -> t
--          Nothing -> error "no transactions"
--    let vout = case listToMaybe $ toList $ Btc.decVout trs of
--          Just v -> v
--          Nothing -> error "no vout"
--    let expS :: Word64 = 3600 * 24 * 365 * 10
--        outP = newOutPoint (getTxOut $ Btc.decTxId trs) (getVout vout)
--        lockId = newLockId0 (getTxOut $ Btc.decTxId trs) (getVout vout)
--  where
--    getVout (Btc.TxOut _ vout _) = tryFrom vout
--    getTxOut txid = txIdParser $ Btc.unTransactionID txid
--    newLockId0 ::
--      Either LndError ByteString ->
--      Either (TryFromException Integer (Vout 'Funding)) (Vout 'Funding) ->
--      UtxoLockId
--    newLockId0 (Right txid0) (Right vout0) = do
--      let txid1 :: TxId 'Funding = from txid0
--      let txid = L.fromStrict $ coerce txid1
--          vout = Universum.show vout0
--      UtxoLockId
--        . L.toStrict
--        . SHA.bytestringDigest
--        . SHA.sha256
--        $ txid <> ":" <> vout
--    newLockId0 _ _ = error "newLockId0 error"
--    newOutPoint ::
--      Either LndError ByteString ->
--      Either (TryFromException Integer (Vout 'Funding)) (Vout 'Funding) ->
--      OP.OutPoint
--    newOutPoint (Right txid0) (Right vout0) = do
--      let txid1 :: TxId 'Funding = from txid0
--      let txid = coerce txid1
--          vout = coerce vout0
--      OP.OutPoint txid vout
--    newOutPoint _ _ = error "newOutPoint error"

--waitTillNodesSynchronized :: (MonadReader (TestEnv o) m, Env m) => Int -> m (Either Failure ())
--waitTillNodesSynchronized 0 = return $ Left $ FailureInternal "Cannot be synchronized"
--waitTillNodesSynchronized n = runExceptT $ do
--  sleep1s
--  blockCount1 <- withBtcT Btc.getBlockCount id
--  blockCount2 <- withBtc2T Btc.getBlockCount id
--  if blockCount1 == blockCount2
--    then do
--      blockHash1 <- withBtcT Btc.getBlockHash ($ blockCount1)
--      blockHash2 <- withBtc2T Btc.getBlockHash ($ blockCount2)
--      if blockHash1 == blockHash2
--        then return ()
--        else ExceptT $ waitTillNodesSynchronized (n -1)
--    else ExceptT $ waitTillNodesSynchronized (n -1)
