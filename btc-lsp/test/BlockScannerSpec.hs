{-# LANGUAGE TypeApplications #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import LndClient.LndTest (mine)
import qualified Network.Bitcoin as Btc
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  itEnv "Block scanner works with 1 block" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      trAddr <-
        from
          . swapIntoLnFundAddress
          . entityVal
          <$> createDummySwap "one block" Nothing
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
          . BlockScanner.trySat2MSat
          $ amt * 2
      utxos <- BlockScanner.scan
      let (gotAmt :: MSat) = sum $ BlockScanner.utxoValue <$> utxos
      pure (expectedAmt == gotAmt)
    liftIO $ shouldBe res (Right True)
  itEnv "Block scanner works with 2 blocks" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      trAddr <-
        from
          . swapIntoLnFundAddress
          . entityVal
          <$> createDummySwap "two blocks" Nothing
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
          . BlockScanner.trySat2MSat
          $ amt * 2
      utxos <- BlockScanner.scan
      let gotAmt = sum $ BlockScanner.utxoValue <$> utxos
      pure (expectedAmt == gotAmt)
    liftIO $ shouldBe res (Right True)
