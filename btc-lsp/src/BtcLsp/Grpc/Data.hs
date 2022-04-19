{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Grpc.Data
  ( GRel (..),
    SigHeaderName,
    TlsCert (..),
    TlsKey (..),
    RawRequestBytes (..),
  )
where

import BtcLsp.Import.Witch
import Data.Aeson (FromJSON (..), withText)
import Text.PrettyPrint.GenericPretty (Out)
import Text.PrettyPrint.GenericPretty.Instance ()
import Universum
import qualified Witch

data GRel
  = Client
  | Server

newtype RawRequestBytes
  = RawRequestBytes ByteString
  deriving stock
    ( Eq,
      Ord,
      Generic
    )

instance Out RawRequestBytes

newtype SigHeaderName
  = SigHeaderName Text
  deriving newtype
    ( Eq,
      Ord,
      Show,
      IsString
    )

instance From SigHeaderName Text

instance From Text SigHeaderName

instance From SigHeaderName ByteString where
  from =
    via @Text

instance TryFrom ByteString SigHeaderName where
  tryFrom =
    from @Text
      `composeTryRhs` tryFrom

newtype TlsCert (rel :: GRel)
  = TlsCert Text
  deriving newtype
    ( Eq,
      Ord,
      Show,
      FromJSON
    )

newtype TlsKey (rel :: GRel)
  = TlsKey Text
  deriving newtype
    ( Eq,
      Ord,
      FromJSON
    )

instance FromJSON SigHeaderName where
  parseJSON =
    withText "SigHeaderName" $
      pure . SigHeaderName
