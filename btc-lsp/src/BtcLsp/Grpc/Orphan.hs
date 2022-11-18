{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Grpc.Orphan () where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified Witch

instance From Word64 Msat where
  from = via @Natural

deriving stock instance Eq CompressMode

deriving stock instance Generic CompressMode

instance FromJSON CompressMode

instance From PortNumber Word32 where
  from = fromIntegral -- Word16 to Word32 is fine.
