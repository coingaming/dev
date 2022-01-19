{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Data.Type
  ( Nonce,
    TableName (..),
    LnInvoice (..),
    LnInvoiceStatus (..),
    LnChanStatus (..),
    Money (..),
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
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Language.Haskell.TH.Syntax as TH
import qualified LndClient as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto

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

data SwapStatus
  = SwapNew
  | SwapWaitingFund
  | SwapProcessing
  | SwapWaitingRefund
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
  deriving stock
    ( Eq,
      Ord,
      Show,
      Generic
    )

instance Out Failure

Psql.derivePersistField "LnInvoiceStatus"

Psql.derivePersistField "LnChanStatus"

Psql.derivePersistField "SwapStatus"
