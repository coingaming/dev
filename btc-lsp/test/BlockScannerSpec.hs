{-# LANGUAGE TypeApplications #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Math.OnChain as Math
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import LndClient.LndTest (mine)
import qualified Network.Bitcoin as Btc
import Test.Hspec
import TestAppM
import TestHelpers
import TestOrphan ()

spec :: Spec
spec = do
  itEnvT @'LndLsp "Block scanner works with 1 block" $ do
    wbal <- withBtcT Btc.getBalance id
    let amt = wbal / 10
    trAddr <-
      from
        . swapIntoLnFundAddress
        . entityVal
        <$> createDummySwap Nothing
    void $
      withBtcT
        Btc.sendToAddress
        (\h -> h trAddr amt Nothing Nothing)
    void $
      withBtcT
        Btc.sendToAddress
        (\h -> h trAddr amt Nothing Nothing)
    lift $ mine 1 LndLsp
    expectedAmt <-
      except
        . first (const (FailureInternal "expectedAmt overflow"))
        . Math.trySatToMsat
        $ amt * 2
    utxos <- BlockScanner.scan
    let gotAmt :: MSat = sum $ BlockScanner.utxoAmt <$> utxos
    liftIO $ expectedAmt `shouldBe` gotAmt
  itEnvT @'LndLsp "Block scanner works with 2 blocks" $ do
    wbal <- withBtcT Btc.getBalance id
    let amt = wbal / 10
    trAddr <-
      from
        . swapIntoLnFundAddress
        . entityVal
        <$> createDummySwap Nothing
    void $
      withBtcT
        Btc.sendToAddress
        (\h -> h trAddr amt Nothing Nothing)
    lift $ mine 1 LndLsp
    void $
      withBtcT
        Btc.sendToAddress
        (\h -> h trAddr amt Nothing Nothing)
    lift $ mine 1 LndLsp
    expectedAmt <-
      except . first (const (FailureInternal "expectedAmt overflow"))
        . Math.trySatToMsat
        $ amt * 2
    utxos <- BlockScanner.scan
    let gotAmt = sum $ BlockScanner.utxoAmt <$> utxos
    liftIO $ expectedAmt `shouldBe` gotAmt
  itEnvT @'LndLsp "Block scanner detects dust" $ do
    let amt0 = Math.trxDustLimit
    let amt1 = amt0 + 3000
    let amt2 = amt0 - 2000
    swapEnt <-
      createDummySwap Nothing
    let trAddr =
          from
            . swapIntoLnFundAddress
            $ entityVal swapEnt
    satsToSend <-
      mapM
        Math.tryMsatToSatT
        [amt0, amt1, amt2]
    mapM_
      ( \amt ->
          withBtcT
            Btc.sendToAddress
            (\h -> h trAddr amt Nothing Nothing)
      )
      satsToSend
    lift $
      mine 1 LndLsp
    scanUtxos <-
      BlockScanner.scan
    dbUtxos <-
      lift
        . runSql
        . (entityVal <<$>>)
        . SwapUtxo.getUtxosBySwapIdSql
        $ entityKey swapEnt
    let dbUtxosSpendable =
          filter
            ((== SwapUtxoUnspent) . swapUtxoStatus)
            dbUtxos
    let dbUtxosDust =
          filter
            ((== SwapUtxoUnspentDust) . swapUtxoStatus)
            dbUtxos
    liftIO $ do
      length scanUtxos
        `shouldBe` 3
      sum (BlockScanner.utxoAmt <$> scanUtxos)
        `shouldBe` amt0 + amt1 + amt2
      length dbUtxos
        `shouldBe` 3
      length dbUtxosSpendable
        `shouldBe` 2
      length dbUtxosDust
        `shouldBe` 1
      sum (swapUtxoAmount <$> dbUtxosSpendable)
        `shouldBe` from (amt0 + amt1)
      sum (swapUtxoAmount <$> dbUtxosDust)
        `shouldBe` from amt2
