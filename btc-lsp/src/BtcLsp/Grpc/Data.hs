{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Grpc.Data
  ( GRel (..),
    SigHeaderName (..),
    TlsCert (..),
    TlsKey (..),
    RawRequestBytes (..)
  )
where

import Data.Aeson (FromJSON (..), withText)
import qualified Data.Text.Encoding as TE
import Text.PrettyPrint.GenericPretty.Instance ()
import Universum

data GRel = Client | Server

newtype RawRequestBytes = RawRequestBytes ByteString

newtype SigHeaderName
  = SigHeaderName ByteString
  deriving
    ( Eq,
      Ord,
      Show,
      IsString
    )

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
    withText "SigHeaderName" $ pure . SigHeaderName . TE.encodeUtf8
