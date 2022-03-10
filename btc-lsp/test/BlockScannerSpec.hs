module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified Data.Map as M
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

genLspAddress ::
  ExceptT
    Failure
    (TestAppM 'LndLsp IO)
    Lnd.NewAddressResponse
genLspAddress =
  withLndT
    Lnd.newAddress
    ( $
        Lnd.NewAddressRequest
          { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
            Lnd.account = Nothing
          }
    )

btcToMSat :: Btc.BTC -> MSat
btcToMSat x = MSat $ fromIntegral (i * 1000)
  where
    (i :: Integer) = from x

spec :: Spec
spec = do
  itEnv "Block scanner works with 1 block" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      (Lnd.NewAddressResponse trAddr) <- genLspAddress
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h trAddr amt Nothing Nothing)
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h trAddr amt Nothing Nothing)
      lift $ mine 1 LndLsp
      let expectedAmt = btcToMSat amt * 2
      foundAmt <-
        M.lookup
          trAddr
          <$> BlockScanner.scanT (const $ pure True)
      pure $ (==) <$> Just expectedAmt <*> foundAmt
    liftIO $ shouldBe res (Right (Just True))
  itEnv "Block scanner works with 2 blocks" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      (Lnd.NewAddressResponse trAddr) <- genLspAddress
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
      let expectedAmt = btcToMSat amt * 2
      foundAmt <-
        M.lookup
          trAddr
          <$> BlockScanner.scanT (const $ pure True)
      pure $ (==) <$> Just expectedAmt <*> foundAmt
    liftIO $ shouldBe res (Right (Just True))
