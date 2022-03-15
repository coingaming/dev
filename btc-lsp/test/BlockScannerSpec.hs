{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
--import qualified Data.Map as M

import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapIntoLn as SWP
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified LndClient as Lnd
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

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

insertFakeUser :: (Storage m, Env m) => ByteString -> m (Entity User)
insertFakeUser key = do
  ct <- getCurrentTime
  let u =
        User
          { userNodePubKey = NodePubKey key,
            userLatestNonce = from @Word64 0,
            userInsertedAt = ct,
            userUpdatedAt = ct
          }
  runSql $ Psql.insertEntity u

createDummySwap :: ByteString -> ExceptT Failure (TestAppM 'LndLsp IO) (Entity SwapIntoLn)
createDummySwap key = do
  u <- lift $ insertFakeUser key
  fundAddr <- genAddress LndLsp
  refundAddr <- genAddress LndAlice
  fundInv <- genPaymentReq
  expAt <- lift $ getFutureTime (Lnd.Seconds 3600)
  lift $ SWP.createIgnore u fundInv (from fundAddr) (from refundAddr) expAt

spec :: Spec
spec = do
  itEnv "Block scanner works with 1 block" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      trAddr <- from . swapIntoLnFundAddress . entityVal <$> createDummySwap "one block"
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h trAddr amt Nothing Nothing)
      void $
        withBtcT
          Btc.sendToAddress
          (\h -> h trAddr amt Nothing Nothing)
      lift $ mine 1 LndLsp
      let expectedAmt = from amt * 2
      utxos <- BlockScanner.scan
      let (gotAmt :: MSat) = sum $ from . BlockScanner.utxoValue <$> utxos
      pure (expectedAmt == gotAmt)
    liftIO $ shouldBe res (Right True)
  itEnv "Block scanner works with 2 blocks" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      trAddr <- from . swapIntoLnFundAddress . entityVal <$> createDummySwap "two blocks"
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
      let expectedAmt = from amt * 2
      utxos <- BlockScanner.scan
      let (gotAmt :: MSat) = sum $ from . BlockScanner.utxoValue <$> utxos
      pure (expectedAmt == gotAmt)
    liftIO $ shouldBe res (Right True)
