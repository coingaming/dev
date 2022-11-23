{-# OPTIONS_GHC -Wno-orphans #-}

module TestOrphan () where

import BtcLsp.Import
import qualified LndClient.Data.NewAddress as Lnd
import Test.QuickCheck
import qualified Witch

instance From Lnd.NewAddressResponse (OnChainAddress 'Refund) where
  from =
    unsafeNewOnChainAddress . coerce

instance From (OnChainAddress 'Refund) Lnd.NewAddressResponse where
  from =
    coerce . unOnChainAddress

instance Arbitrary Msat where
  arbitrary =
    Msat . from <$> arbitrary @Word64
