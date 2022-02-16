{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Data.Type
  ( Nonce,
    newNonce,
    TableName (..),
    LnInvoice (..),
    LnInvoiceStatus (..),
    LnChanStatus (..),
    Money (..),
    FeeRate (..),
    OnChainAddress (..),
    FieldIndex (..),
    ReversedFieldLocation (..),
    Seconds (..),
    LogFormat (..),
    MicroSeconds (..),
    TaskRes (..),
    Timing (..),
    SwapStatus (..),
    Failure (..),
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Data.Time.Clock as Clock
import Data.Time.Clock.POSIX (posixSecondsToUTCTime)
import qualified Language.Haskell.TH.Syntax as TH
import qualified LndClient as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
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

newtype FieldIndex
  = FieldIndex Word32
  deriving
    ( TH.Lift,
      Show
    )

newtype ReversedFieldLocation
  = ReversedFieldLocation [FieldIndex]
  deriving
    ( TH.Lift,
      Semigroup,
      Show
    )

data LogFormat
  = Bracket
  | JSON
  deriving
    ( Read
    )

newtype Seconds
  = Seconds Word64
  deriving
    ( Eq,
      Ord,
      Show,
      Num,
      Generic
    )

instance Out Seconds

newtype MicroSeconds
  = MicroSeconds Integer
  deriving
    ( Eq,
      Ord,
      Show,
      Num,
      Generic
    )

instance Out MicroSeconds

data TaskRes
  = TaskResDoNotRetry
  | TaskResRetryAfter MicroSeconds
  deriving
    ( Eq,
      Ord,
      Show
    )

data TableName
  = UserTable
  | LnChanTable
  deriving
    ( Enum
    )

newtype LnInvoice (mrel :: MoneyRelation)
  = LnInvoice Lnd.PaymentRequest
  deriving newtype
    ( Eq,
      Show,
      Psql.PersistField,
      Psql.PersistFieldSql
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
  deriving
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
  | LnChanStatusInactive
  | LnChanStatusPendingClose
  | LnChanStatusClosed
  deriving
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
    (mrel :: MoneyRelation)
  = Money MSat
  deriving newtype
    ( Eq,
      Ord,
      Show,
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
  = FeeRate (Ratio Natural)
  deriving newtype
    ( Eq,
      Ord,
      Show
    )
  deriving stock
    ( Generic
    )

instance From (Ratio Natural) FeeRate

instance From FeeRate (Ratio Natural)

instance TryFrom Rational FeeRate where
  tryFrom =
    from @(Ratio Natural)
      `composeTryRhs` tryFrom

instance From FeeRate Rational where
  from =
    via @(Ratio Natural)

newtype OnChainAddress (mrel :: MoneyRelation)
  = OnChainAddress Text
  deriving newtype
    ( Eq,
      Ord,
      Show,
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
    SwapWaitingFund
  | -- | Waiting channel opening trx
    -- to be mined with some confirmations.
    SwapWaitingChan
  | -- | Swap has been funded with insufficient
    -- non-dust amt, but funding invoice has
    -- been expired. Then lsp is doing refund
    -- into given refund on-chain address and
    -- waiting for some confirmations.
    SwapWaitingRefund
  | -- | Final statuses
    SwapRefunded
  | SwapSucceeded
  deriving
    ( Eq,
      Ord,
      Show,
      Read,
      Generic,
      Enum,
      Bounded
    )

instance Out SwapStatus

data Timing
  = Permanent
  | Temporary
  deriving
    ( Generic,
      Show,
      Eq,
      Ord
    )

data Error a = Error
  { unTiming :: Timing,
    unError :: a
  }
  deriving
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
  deriving stock
    ( Eq,
      Show,
      Generic
    )

instance Out Failure

Psql.derivePersistField "LnInvoiceStatus"

Psql.derivePersistField "LnChanStatus"

Psql.derivePersistField "SwapStatus"
