{-# OPTIONS_GHC -Wno-orphans #-}

module TestOrphan () where

import BtcLsp.Import
import Test.QuickCheck

instance Arbitrary Msat where
  arbitrary =
    Msat . from <$> arbitrary @Word64
