{-# LANGUAGE DeriveLift #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Data.Type
  ( TableName (..),
    LnInvoiceStatus (..),
    LnChannelStatus (..),
    FieldIndex (..),
    ReversedFieldLocation (..),
    Seconds (..),
    LogFormat (..),
    MicroSeconds (..),
    TaskRes (..),
    Timing (..),
  )
where

import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Language.Haskell.TH.Syntax as TH

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
  = LnChannelTable
  deriving
    ( Enum
    )

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

data LnChannelStatus
  = LnChannelStatusPendingOpen
  | LnChannelStatusOpened
  | LnChannelStatusActive
  | LnChannelStatusInactive
  | LnChannelStatusPendingClose
  | LnChannelStatusClosed
  deriving
    ( Generic,
      Show,
      Read,
      Eq,
      Ord
    )

instance Out LnChannelStatus

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

Psql.derivePersistField "LnInvoiceStatus"

Psql.derivePersistField "LnChannelStatus"
