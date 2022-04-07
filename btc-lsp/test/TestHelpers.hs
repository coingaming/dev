{-# LANGUAGE TypeApplications #-}
module TestHelpers
  (genAddress, createDummySwap)
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.SwapIntoLn as SWP
import qualified Database.Persist as Psql
import qualified LndClient as Lnd
import qualified LndClient.Data.AddInvoice as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.RPC.Katip as Lnd
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
