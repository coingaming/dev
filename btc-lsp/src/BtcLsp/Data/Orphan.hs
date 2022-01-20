{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Data.Orphan () where

import BtcLsp.Import.External
import qualified LndClient as Lnd

--
-- TODO : smart constuctors are needed!!!
--

instance From Text Lnd.PaymentRequest

instance From Lnd.PaymentRequest Text

instance From Word64 MSat

instance From MSat Word64

instance From Word64 Lnd.Seconds

instance From Lnd.Seconds Word64
