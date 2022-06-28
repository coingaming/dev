module TestHelpers
  ( genAddress,
    createDummySwap,
    getLatestBlock,
    putLatestBlockToDB,
    waitCond,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.User as User
import qualified LndClient as Lnd
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Silent as Lnd
import qualified Network.Bitcoin as Btc
import TestAppM
import TestOrphan ()
import qualified BtcLsp.Storage.Model.Block as Block

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

genPayReq ::
  TestOwner ->
  ExceptT Failure (TestAppM 'LndLsp IO) Lnd.AddInvoiceResponse
genPayReq owner =
  withLndTestT
    owner
    Lnd.addInvoice
    ( $
        Lnd.AddInvoiceRequest
          { Lnd.valueMsat = MSat 0,
            Lnd.memo = Nothing,
            Lnd.expiry =
              Just
                . Lnd.Seconds
                $ 7 * 24 * 3600
          }
    )

genUser ::
  TestOwner ->
  ExceptT Failure (TestAppM 'LndLsp IO) (Entity User)
genUser owner = do
  alicePub <- getPubKeyT owner
  nonce <- lift newNonce
  ExceptT . runSql $ User.createVerifySql alicePub nonce

createDummySwap ::
  Maybe UTCTime ->
  ExceptT Failure (TestAppM 'LndLsp IO) (Entity SwapIntoLn)
createDummySwap mExpAt = do
  usr <- genUser LndAlice
  payReq <- genPayReq LndAlice
  fundAddr <- genAddress LndLsp
  changeAndFeeAddr <- genAddress LndLsp
  refundAddr <- genAddress LndAlice
  expAt <-
    maybeM
      (getFutureTime (Lnd.Seconds 3600))
      pure
      $ pure mExpAt
  lift . runSql $
    SwapIntoLn.createIgnoreSql
      usr
      (from $ Lnd.paymentRequest payReq)
      (Lnd.rHash payReq)
      (from fundAddr)
      (coerce changeAndFeeAddr)
      (from refundAddr)
      expAt
      Public

getLatestBlock :: ExceptT Failure (TestAppM 'LndLsp IO) Btc.BlockVerbose
getLatestBlock = do
  blkCount <- withBtcT Btc.getBlockCount id
  hash <- withBtcT Btc.getBlockHash ($ blkCount)
  withBtcT Btc.getBlockVerbose ($ hash)

putLatestBlockToDB :: ExceptT Failure (TestAppM 'LndLsp IO) (Btc.BlockVerbose, Entity Block)
putLatestBlockToDB = do
  blk <- getLatestBlock
  height <- tryFromT $
      Btc.vBlkHeight blk
  k <-
    lift . runSql $
      Block.createUpdateConfirmedSql
        height
        (from $ Btc.vBlockHash blk)
  pure (blk, k)

waitCond ::
  ( Env m,
    LndTest m TestOwner
  ) =>
  Integer ->
  (a -> m (Bool, a)) ->
  a ->
  m (Bool, a)
waitCond times condition st = do
  (cond, newSt) <- condition st
  if cond
    then pure (True, newSt)
    else
      if times == 0
        then pure (False, newSt)
        else do
          sleep1s
          mine 1 LndLsp
          waitCond (times - 1) condition newSt
