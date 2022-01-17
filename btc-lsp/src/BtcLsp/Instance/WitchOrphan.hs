{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Instance.WitchOrphan () where

import BtcLsp.Data.Type
import BtcLsp.Import.External
import Lens.Micro
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Witch

--
-- TODO : maybe smart constraints are needed?
--

instance From Proto.Nonce Nonce where
  from =
    Nonce . (^. Proto.val)

instance From Proto.LnPubKey NodePubKey where
  from =
    NodePubKey . (^. Proto.val)
