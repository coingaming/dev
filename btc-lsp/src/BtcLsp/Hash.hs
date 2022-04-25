{-# LANGUAGE TypeApplications #-}

module BtcLsp.Hash
  ( Sha256,
    HexSha256,
    Hash (..),
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Crypto.Hash.SHA256 as SHA256 (hash)
import qualified Data.ByteString.Base16 as B16
import qualified Witch

newtype Sha256 a = Sha256
  { unSha256 :: ByteString
  }
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

instance Out (Sha256 a)

newtype HexSha256 a = HexSha256
  { unHexSha256 :: Text
  }
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

instance Out (HexSha256 a)

instance From (Sha256 a) (HexSha256 a) where
  from =
    --
    -- NOTE : decodeUtf8 in general is unsafe
    -- but here we know that it will not fail
    -- because of B16
    --
    HexSha256
      . decodeUtf8
      . B16.encode
      . unSha256

instance From (HexSha256 a) (Sha256 a) where
  from =
    --
    -- NOTE : this is not RFC 4648-compliant,
    -- using only for the practical purposes
    --
    Sha256
      . B16.decodeLenient
      . encodeUtf8
      . unHexSha256

class Hash a where
  sha256 :: a -> Sha256 a
  hexSha256 :: a -> HexSha256 a
  hexSha256 =
    from
      . sha256

instance Hash (LnInvoice (mrel :: MoneyRelation)) where
  sha256 =
    Sha256
      . SHA256.hash
      . encodeUtf8
      . into @Text

instance ToMessage (HexSha256 (LnInvoice (mrel :: MoneyRelation))) where
  toMessage =
    unHexSha256
