{-# OPTIONS_GHC -Wno-orphans #-}

module TestOrphan () where

import BtcLsp.Import
import qualified LndClient.Data.NewAddress as Lnd

instance From Lnd.NewAddressResponse (OnChainAddress 'Refund)

instance From (OnChainAddress 'Refund) Lnd.NewAddressResponse
