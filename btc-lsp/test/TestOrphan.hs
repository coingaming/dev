{-# OPTIONS_GHC -Wno-orphans #-}

module TestOrphan () where

import BtcLsp.Import
import qualified LndClient.Data.NewAddress as Lnd
import Test.QuickCheck

instance From Lnd.NewAddressResponse (OnChainAddress 'Refund)

instance From (OnChainAddress 'Refund) Lnd.NewAddressResponse

deriving newtype instance Arbitrary MSat
