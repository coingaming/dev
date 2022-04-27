{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Grpc.Data
  ( GRel (..),
    SigHeaderName,
    TlsCert (..),
    TlsKey (..),
    TlsData (..),
    RawRequestBytes (..),
    Encryption (..),
  )
where

import BtcLsp.Import.Witch
import Data.Aeson (FromJSON (..), withObject, withText, (.:))
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

data TlsData (rel :: GRel) = TlsData
  { tlsCert :: TlsCert rel,
    tlsKey :: TlsKey rel
  }
  deriving stock
    ( Eq,
      Ord
    )

instance FromJSON (TlsData (rel :: GRel)) where
  parseJSON =
    withObject
      "TlsData"
      $ \x ->
        TlsData
          <$> x .: "cert"
          <*> x .: "key"

instance FromJSON SigHeaderName where
  parseJSON =
    withText "SigHeaderName" $
      pure . SigHeaderName

data Encryption
  = Encrypted
  | UnEncrypted
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Enum,
      Bounded,
      Generic
    )

instance Out Encryption

instance FromJSON Encryption
