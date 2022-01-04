{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.ProtoLensGrpc.Data
  ( GRel (..),
    PrvKey (..),
    PubKey (..),
    Sig (..),
    SigHeaderName (..),
    TlsCert (..),
    TlsKey (..),
    sign,
    verify,
  )
where

import Data.Aeson (FromJSON (..), withText)
import Data.Coerce (coerce)
import Data.Signable (Signable)
import qualified Data.Signable as Signable
import qualified Data.Text.Encoding as TE
import Universum
import qualified Prelude

data GRel = Client | Server

newtype PrvKey (rel :: GRel)
  = PrvKey Signable.PrvKey
  deriving (Eq)

newtype PubKey (rel :: GRel)
  = PubKey Signable.PubKey
  deriving (Eq, Show)

newtype Sig (rel :: GRel)
  = Sig Signable.Sig
  deriving (Eq, Show)

newtype SigHeaderName
  = SigHeaderName ByteString
  deriving (Eq, Ord, Show, IsString)

newtype TlsCert (rel :: GRel)
  = TlsCert Text
  deriving newtype (Eq, Ord, Show, FromJSON)

newtype TlsKey (rel :: GRel)
  = TlsKey Text
  deriving newtype (Eq, Ord, FromJSON)

sign ::
  ( Signable a
  ) =>
  PrvKey rel ->
  a ->
  Sig rel
sign k =
  Sig
    . Signable.sign (coerce k)

verify ::
  ( Signable a
  ) =>
  PubKey rel ->
  Sig rel ->
  a ->
  Bool
verify k s =
  Signable.verify
    (coerce k)
    (coerce s)

instance Prelude.Show (PrvKey rel) where
  show = const "SECRET"

instance Prelude.Show (TlsKey rel) where
  show = const "SECRET"

instance FromJSON (PrvKey rel) where
  parseJSON =
    withText "PrvKeySecp256k1" $ \pem ->
      case Signable.importPrvKeyPem Signable.AlgSecp256k1 $ TE.encodeUtf8 pem of
        Right x -> pure $ PrvKey x
        Left e -> fail $ show e

instance FromJSON (PubKey rel) where
  parseJSON =
    withText "PubKeySecp256k1" $ \pem ->
      case Signable.importPubKeyPem Signable.AlgSecp256k1 $ TE.encodeUtf8 pem of
        Right x -> pure $ PubKey x
        Left e -> fail $ show e

instance FromJSON SigHeaderName where
  parseJSON =
    withText "SigHeaderName" $ pure . SigHeaderName . TE.encodeUtf8
