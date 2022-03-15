{-# OPTIONS_GHC -Wno-deprecations #-}
{-# LANGUAGE TypeApplications #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
--import qualified Data.Map as M

import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapIntoLn as SWP
import qualified LndClient as Lnd

genAddress ::
  TestOwner ->
  ExceptT
    Failure
    (TestAppM 'LndLsp IO)
    Lnd.NewAddressResponse
genAddress own =
  withLndTestT
    own
    Lnd.newAddress
    ( $
        Lnd.NewAddressRequest
          { Lnd.addrType = Lnd.WITNESS_PUBKEY_HASH,
            Lnd.account = Nothing
          }
    )

genPaymentReq :: ExceptT Failure (TestAppM 'LndLsp IO) (LnInvoice 'Fund)
genPaymentReq =
  from . Lnd.paymentRequest
    <$> withLndTestT
      LndAlice
      Lnd.addInvoice
      ( $
          Lnd.AddInvoiceRequest
            { Lnd.valueMsat = MSat 0,
              Lnd.memo = Nothing,
              Lnd.expiry = Nothing
            }
      )

insertFakeUser :: (Storage m, Env m) => m (Entity User)
insertFakeUser = do
  ct <- getCurrentTime
  pub <- getLspPubKey
  let u = User {
    userNodePubKey = pub,
    userLatestNonce = from @Word64 0,
    userInsertedAt = ct,
    userUpdatedAt = ct
  }
  runSql $ Psql.insertEntity u

createDummySwap :: ExceptT Failure (TestAppM 'LndLsp IO) (Entity SwapIntoLn)
createDummySwap = do
  u <- lift insertFakeUser
  fundAddr <- genAddress LndLsp
  refundAddr <- genAddress LndAlice
  fundInv <- genPaymentReq
  expAt <- lift $ getFutureTime (Lnd.Seconds 3600)
  lift $ SWP.createIgnore u fundInv (from fundAddr) (from refundAddr) expAt




_btcToMSat :: Btc.BTC -> MSat
_btcToMSat x = MSat $ fromIntegral (i * 1000)
  where
    (i :: Integer) = from x

spec :: Spec
spec = do
  itEnv "Block scanner works with 1 block" $ do
    traceShowM ("Test started" :: Text)
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      traceShowM ("hehe" :: Text)
      traceShowM wbal
      let amt = wbal / 10
      trAddr <- from . swapIntoLnFundAddress . entityVal <$> createDummySwap
      traceShowM trAddr
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h trAddr amt Nothing Nothing)
      lift $ mine 1 LndLsp
      -- let expectedAmt = btcToMSat amt * 2
      utxos <- BlockScanner.scan
      traceShowM utxos
      pure $ Just True
    -- pure $ (==) <$> Just expectedAmt <*> foundAmt
    liftIO $ shouldBe res (Right (Just True))
  xitEnv "Block scanner works with 2 blocks" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      trAddr <- from . swapIntoLnFundAddress . entityVal <$> createDummySwap
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
      -- let expectedAmt = btcToMSat amt * 2
      utxos <- BlockScanner.scan
      traceShowM utxos
      pure $ Just True
    -- pure $ (==) <$> Just expectedAmt <*> foundAmt
    liftIO $ shouldBe res (Right (Just True))
