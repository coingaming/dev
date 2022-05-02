{-# LANGUAGE TypeApplications #-}

module TestHelpers
  ( genAddress,
    createDummySwap,
    getLatestBlock,
    putLatestBlockToDB,
    waitCond,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SWP
import qualified Database.Persist as Psql
import qualified LndClient as Lnd
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Silent as Lnd
import qualified Network.Bitcoin as Btc
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

genPaymentReq :: ExceptT Failure (TestAppM 'LndLsp IO) Lnd.AddInvoiceResponse
genPaymentReq =
  withLndTestT
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

createDummySwap ::
  ByteString ->
  Maybe UTCTime ->
  ExceptT Failure (TestAppM 'LndLsp IO) (Entity SwapIntoLn)
createDummySwap key mExpAt = do
  usr <- lift $ insertFakeUser key
  fundAddr <- genAddress LndLsp
  refundAddr <- genAddress LndAlice
  payReq <- genPaymentReq
  expAt <-
    maybeM
      (getFutureTime (Lnd.Seconds 3600))
      pure
      $ pure mExpAt
  lift $
    SWP.createIgnore
      usr
      (from $ Lnd.paymentRequest payReq)
      (Lnd.rHash payReq)
      (from fundAddr)
      (from refundAddr)
      expAt

getLatestBlock :: ExceptT Failure (TestAppM 'LndLsp IO) Btc.BlockVerbose
getLatestBlock = do
  blkCount <- withBtcT Btc.getBlockCount id
  hash <- withBtcT Btc.getBlockHash ($ blkCount)
  withBtcT Btc.getBlockVerbose ($ hash)

putLatestBlockToDB :: ExceptT Failure (TestAppM 'LndLsp IO) (Btc.BlockVerbose, Entity Block)
putLatestBlockToDB = do
  blk <-
    getLatestBlock
  height <-
    tryFromT $
      Btc.vBlkHeight blk
  k <-
    lift . runSql $
      Block.createUpdateSql
        height
        (from $ Btc.vBlockHash blk)
        (from <$> Btc.vPrevBlock blk)
  pure (blk, k)

waitCond :: (Env m, LndTest m TestOwner) => Integer -> (a -> m (Bool, a)) -> a -> m Bool
waitCond times condition st = do
  (cond, newSt) <- condition st
  if cond
    then pure True
    else
      if times == 0
        then pure False
        else do
          sleep $ MicroSecondsDelay 1000000
          mine 1 LndLsp
          waitCond (times - 1) condition newSt
