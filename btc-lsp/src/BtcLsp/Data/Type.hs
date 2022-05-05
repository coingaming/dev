{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Data.Type
  ( Nonce,
    newNonce,
    LnInvoice (..),
    LnInvoiceStatus (..),
    LnChanStatus (..),
    Money (..),
    FeeRate (..),
    OnChainAddress (..),
    Seconds (..),
    LogFormat (..),
    MicroSeconds (..),
    TaskRes (..),
    Timing (..),
    SwapStatus (..),
    Failure (..),
    tryFailureE,
    tryFailureT,
    tryFromE,
    tryFromT,
    RpcError (..),
    SocketAddress (..),
    BlkHash (..),
    BlkPrevHash (..),
    BlkHeight (..),
    BlkStatus (..),
    SwapUtxoStatus (..),
    Privacy (..),
    NodePubKeyHex (..),
    NodeUri (..),
    NodeUriHex (..),
    UtxoLockId (..),
    RHashHex (..),
    Uuid,
    unUuid,
    newUuid,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Data.ByteString.Base16 as B16
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import qualified Data.Time.Clock as Clock
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import qualified LndClient as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import qualified Network.Bitcoin.BlockChain as Btc
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Universum
import qualified Witch

newtype Nonce
  = Nonce Word64
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out Nonce

instance From Nonce Word64

instance From Word64 Nonce

newNonce :: (MonadIO m) => m Nonce
newNonce =
  liftIO $
    Nonce
      . utcTimeToMicros
      <$> Clock.getCurrentTime

utcTimeToMicros :: UTCTime -> Word64
utcTimeToMicros x =
  fromInteger $
    diffTimeToPicoseconds
      ( fromRational
          . toRational
          $ diffUTCTime x epoch
      )
      `div` 1000000

epoch :: UTCTime
epoch =
  posixSecondsToUTCTime 0

data LogFormat
  = Bracket
  | JSON
  deriving stock
    ( Read
    )

newtype Seconds
  = Seconds Word64
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out Seconds

newtype MicroSeconds
  = MicroSeconds Integer
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Num
    )
  deriving stock
    ( Generic
    )

instance Out MicroSeconds

data TaskRes
  = TaskResDoNotRetry
  | TaskResRetryAfter MicroSeconds
  deriving stock
    ( Eq,
      Ord,
      Show
    )

newtype LnInvoice (mrel :: MoneyRelation)
  = LnInvoice Lnd.PaymentRequest
  deriving newtype
    ( Eq,
      Show,
      Psql.PersistField,
      Psql.PersistFieldSql,
      PathPiece
    )
  deriving stock
    ( Generic
    )

instance Out (LnInvoice mrel)

instance From Lnd.PaymentRequest (LnInvoice mrel)

instance From (LnInvoice mrel) Lnd.PaymentRequest

instance From Text (LnInvoice mrel) where
  from =
    via @Lnd.PaymentRequest

instance From (LnInvoice mrel) Text where
  from =
    via @Lnd.PaymentRequest

data LnInvoiceStatus
  = LnInvoiceStatusNew
  | LnInvoiceStatusLocked
  | LnInvoiceStatusSettled
  | LnInvoiceStatusCancelled
  | LnInvoiceStatusExpired
  deriving stock
    ( Generic,
      Show,
      Read,
      Eq
    )

instance Out LnInvoiceStatus

data LnChanStatus
  = LnChanStatusPendingOpen
  | LnChanStatusOpened
  | LnChanStatusActive
  | LnChanStatusFullyResolved
  | LnChanStatusInactive
  | LnChanStatusPendingClose
  | LnChanStatusClosed
  deriving stock
    ( Generic,
      Show,
      Read,
      Eq,
      Ord
    )

instance Out LnChanStatus

newtype
  Money
    (owner :: Owner)
    (btcl :: BitcoinLayer)
    (mrel :: MoneyRelation) = Money
  { unMoney :: MSat
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      Num,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out (Money owner btcl mrel)

instance From MSat (Money owner btcl mrel)

instance From (Money owner btcl mrel) MSat

instance From Word64 (Money owner btcl mrel) where
  from =
    via @MSat

instance From (Money owner btcl mrel) Word64 where
  from =
    via @MSat

instance TryFrom Natural (Money owner btcl mrel) where
  tryFrom =
    from @Word64 `composeTryRhs` tryFrom

instance From (Money owner btcl mrel) Natural where
  from =
    via @Word64

instance TryFrom (Ratio Natural) (Money owner btcl mrel) where
  tryFrom =
    tryFrom @Natural
      `composeTry` tryFrom

instance From (Money owner btcl mrel) (Ratio Natural) where
  from =
    via @Natural

instance TryFrom Rational (Money owner btcl mrel) where
  tryFrom =
    tryFrom @(Ratio Natural)
      `composeTry` tryFrom

instance From (Money owner btcl mrel) Rational where
  from =
    via @(Ratio Natural)

newtype FeeRate
  = FeeRate (Ratio Word64)
  deriving newtype
    ( Eq,
      Ord,
      Show
    )
  deriving stock
    ( Generic
    )

instance From (Ratio Word64) FeeRate

instance From FeeRate (Ratio Word64)

instance From FeeRate (Ratio Natural) where
  from =
    via @(Ratio Word64)

instance TryFrom Rational FeeRate where
  tryFrom =
    from @(Ratio Word64)
      `composeTryRhs` tryFrom

instance From FeeRate Rational where
  from =
    via @(Ratio Word64)

newtype OnChainAddress (mrel :: MoneyRelation)
  = OnChainAddress Text
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      PathPiece,
      Psql.PersistField,
      Psql.PersistFieldSql
    )
  deriving stock
    ( Generic
    )

instance Out (OnChainAddress mrel)

instance From Text (OnChainAddress mrel)

instance From (OnChainAddress mrel) Text

instance From Lnd.NewAddressResponse (OnChainAddress 'Fund)

instance From (OnChainAddress 'Fund) Lnd.NewAddressResponse

instance FromJSON (OnChainAddress mrel)

instance ToJSON (OnChainAddress mrel)

data SwapStatus
  = -- | Waiting on-chain funding trx with
    -- given amt from user with
    -- some confirmations.
    SwapWaitingFundChain
  | -- | Swap has been funded on-chain,
    -- need to open LN channel now.
    SwapWaitingPeer
  | -- | Waiting channel opening trx
    -- to be mined with some confirmations.
    SwapWaitingChan
  | -- | Waiting funding LN invoice
    -- to be paid by SwapperIntoLn.
    SwapWaitingFundLn
  | -- | Final statuses
    SwapSucceeded
  | SwapExpired
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic,
      Enum,
      Bounded
    )

instance Out SwapStatus

instance PathPiece SwapStatus where
  fromPathPiece :: Text -> Maybe SwapStatus
  fromPathPiece =
    readMaybe
      . unpack
      . T.toTitle
  toPathPiece :: SwapStatus -> Text
  toPathPiece =
    T.toLower
      . Universum.show

data Timing
  = Permanent
  | Temporary
  deriving stock
    ( Generic,
      Show,
      Eq,
      Ord
    )

data Error a = Error
  { unTiming :: Timing,
    unError :: a
  }
  deriving stock
    ( Generic,
      Show,
      Eq,
      Ord
    )

data Failure
  = FailureNonce
  | FailureInput [Proto.InputFailure]
  | FailureLnd Lnd.LndError
  | --
    -- TODO : do proper input/internal
    -- failure proto messages instead.
    --
    FailureGrpc Text
  | FailureElectrs RpcError
  | --
    -- NOTE : can not use SomeException there
    -- because need Eq instance.
    --
    FailureTryFrom Text
  | FailureInternal Text
  | FailureBitcoind RpcError
  deriving stock
    ( Eq,
      Show,
      Generic
    )

instance Out Failure

tryFailureE ::
  forall source target.
  ( Show source,
    Typeable source,
    Typeable target
  ) =>
  Either (TryFromException source target) target ->
  Either Failure target
tryFailureE =
  first $
    FailureTryFrom . Universum.show

tryFailureT ::
  forall source target m.
  ( Show source,
    Typeable source,
    Typeable target,
    Monad m
  ) =>
  Either (TryFromException source target) target ->
  ExceptT Failure m target
tryFailureT =
  except . tryFailureE

tryFromE ::
  forall source target.
  ( Show source,
    Typeable source,
    Typeable target,
    TryFrom source target,
    'False ~ (source == target)
  ) =>
  source ->
  Either Failure target
tryFromE =
  tryFailureE . tryFrom

tryFromT ::
  forall source target m.
  ( Show source,
    Typeable source,
    Typeable target,
    TryFrom source target,
    Monad m,
    'False ~ (source == target)
  ) =>
  source ->
  ExceptT Failure m target
tryFromT =
  except . tryFromE

data RpcError
  = RpcNoAddress
  | RpcJsonDecodeError
  | RpcHexDecodeError
  | CannotSyncBlockchain
  | OtherError Text
  deriving stock
    ( Eq,
      Generic,
      Show
    )

instance Out RpcError

data SocketAddress = SocketAddress
  { socketAddressHost :: HostName,
    socketAddressPort :: PortNumber
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out SocketAddress

newtype BlkHash
  = BlkHash Btc.BlockHash
  deriving stock (Eq, Ord, Show, Generic)
  deriving newtype (Psql.PersistField, Psql.PersistFieldSql)

instance Out BlkHash

instance From Btc.BlockHash BlkHash

instance From BlkHash Btc.BlockHash

newtype BlkPrevHash
  = BlkPrevHash Btc.BlockHash
  deriving stock (Eq, Ord, Show, Generic)
  deriving newtype (Psql.PersistField, Psql.PersistFieldSql)

instance Out BlkPrevHash

instance From Btc.BlockHash BlkPrevHash

instance From BlkPrevHash Btc.BlockHash

newtype BlkHeight
  = BlkHeight Word64
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )
  deriving newtype
    ( Num,
      Psql.PersistField,
      Psql.PersistFieldSql
    )

instance Out BlkHeight

instance ToJSON BlkHeight

instance From Word64 BlkHeight

instance From BlkHeight Word64

instance From BlkHeight Natural where
  from =
    via @Word64

instance TryFrom Btc.BlockHeight BlkHeight where
  tryFrom =
    from @Word64
      `composeTryRhs` tryFrom

instance From BlkHeight Btc.BlockHeight where
  from =
    via @Word64

data BlkStatus
  = BlkConfirmed
  | BlkOrphan
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance Out BlkStatus

data SwapUtxoStatus
  = SwapUtxoUsedForChanFunding
  | SwapUtxoRefunded
  | SwapUtxoFirstSeen
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance Out SwapUtxoStatus

data Privacy
  = Private
  | Public
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Enum,
      Bounded,
      Generic
    )

instance Out Privacy

newtype NodePubKeyHex
  = NodePubKeyHex Text
  deriving newtype (Eq, Ord, Show, Read, IsString)
  deriving stock (Generic)

instance Out NodePubKeyHex

instance From NodePubKeyHex Text

instance From Text NodePubKeyHex

instance TryFrom NodePubKey NodePubKeyHex where
  tryFrom src =
    from
      `composeTryRhs` ( first
                          ( TryFromException src
                              . Just
                              . toException
                          )
                          . TE.decodeUtf8'
                          . B16.encode
                          . coerce
                      )
      $ src

newtype UtxoLockId = UtxoLockId ByteString
  deriving newtype (Eq, Ord, Show, Read)
  deriving stock (Generic)

instance Out UtxoLockId

data NodeUri = NodeUri
  { nodeUriPubKey :: NodePubKey,
    nodeUriSocketAddress :: SocketAddress
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out NodeUri

newtype NodeUriHex
  = NodeUriHex Text
  deriving newtype (Eq, Ord, Show, Read, IsString)
  deriving stock (Generic)

instance Out NodeUriHex

instance From NodeUriHex Text

instance From Text NodeUriHex

instance TryFrom NodeUri NodeUriHex where
  tryFrom src =
    bimap
      (withTarget @NodeUriHex . withSource src)
      ( \pubHex ->
          from @Text $
            from pubHex
              <> "@"
              <> from host
              <> ":"
              <> from (showIntegral port)
      )
      $ tryFrom @NodePubKey @NodePubKeyHex $
        nodeUriPubKey src
    where
      sock = nodeUriSocketAddress src
      host = socketAddressHost sock
      port = socketAddressPort sock

newtype RHashHex = RHashHex
  { unRHashHex :: Text
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read,
      PathPiece
    )
  deriving stock
    ( Generic
    )

instance Out RHashHex

instance From RHashHex Text

instance From Text RHashHex

instance From RHash RHashHex where
  from =
    --
    -- NOTE : decodeUtf8 in general is unsafe
    -- but here we know that it will not fail
    -- because of B16
    --
    RHashHex
      . decodeUtf8
      . B16.encode
      . coerce

instance From RHashHex RHash where
  from =
    --
    -- NOTE : this is not RFC 4648-compliant,
    -- using only for the practical purposes
    --
    RHash
      . B16.decodeLenient
      . encodeUtf8
      . unRHashHex

newtype Uuid (tab :: Table) = Uuid
  { unUuid' :: UUID
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      Read
    )
  deriving stock (Generic)

unUuid :: Uuid tab -> UUID
unUuid =
  unUuid'

instance Out (Uuid tab) where
  docPrec x =
    docPrec x
      . UUID.toText
      . unUuid
  doc =
    docPrec 0

newUuid :: (MonadIO m) => m (Uuid tab)
newUuid =
  liftIO $
    Uuid <$> UUID.nextRandom

--
-- NOTE :  we're taking advantage of
-- PostgreSQL understanding UUID values
--
instance Psql.PersistField (Uuid tab) where
  toPersistValue =
    Psql.PersistLiteral_ Psql.Escaped
      . UUID.toASCIIBytes
      . unUuid
  fromPersistValue = \case
    Psql.PersistLiteral_ Psql.Escaped x ->
      maybe
        ( Left $
            "Failed to deserialize a UUID, got literal: "
              <> inspectPlain x
        )
        ( Right
            . Uuid
        )
        $ UUID.fromASCIIBytes x
    failure ->
      Left $
        "Failed to deserialize a UUID, got: "
          <> inspectPlain failure

instance Psql.PersistFieldSql (Uuid tab) where
  sqlType =
    const $
      Psql.SqlOther "uuid"

instance ToMessage (Uuid tab) where
  toMessage =
    (<> "...")
      . T.take 5
      . UUID.toText
      . unUuid

instance PathPiece (Uuid tab) where
  fromPathPiece =
    (Uuid <$>)
      . UUID.fromText
  toPathPiece =
    UUID.toText
      . unUuid

Psql.derivePersistField "LnInvoiceStatus"
Psql.derivePersistField "LnChanStatus"
Psql.derivePersistField "SwapStatus"
Psql.derivePersistField "BlkStatus"
Psql.derivePersistField "SwapUtxoStatus"
Psql.derivePersistField "UtxoLockId"
