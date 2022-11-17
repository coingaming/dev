{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Class.FromProto
  ( FromProto (..),
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Data.Type
import BtcLsp.Import.External
import Data.ProtoLens.Field
import qualified LndClient as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.LowLevel as Proto

class ('False ~ (proto == haskell)) => FromProto proto haskell where
  fromProto :: proto -> haskell

instance FromProto Proto.Nonce Nonce where
  fromProto =
    Nonce . unProtoVal

instance FromProto Proto.LnPubKey NodePubKey where
  fromProto =
    NodePubKey . unProtoVal

instance FromProto Proto.LnInvoice (LnInvoice mrel) where
  fromProto =
    LnInvoice . Lnd.PaymentRequest . unProtoVal

instance FromProto Proto.FundLnInvoice (LnInvoice 'Fund) where
  fromProto =
    fromProto @Proto.LnInvoice . unProtoVal

instance FromProto Proto.OnChainAddress (UnsafeOnChainAddress 'Refund) where
  fromProto =
    UnsafeOnChainAddress . unProtoVal

instance FromProto Proto.RefundOnChainAddress (UnsafeOnChainAddress 'Refund) where
  fromProto =
    fromProto @Proto.OnChainAddress @(UnsafeOnChainAddress 'Refund)
      . unProtoVal

instance FromProto Proto.Privacy Privacy where
  fromProto =
    toEnum . fromEnum

instance FromProto Proto.Msat Msat where
  fromProto =
    Msat
      . from @Word64 @Natural
      . unProtoVal

-- instance FromProto Proto.FundMoney Msat where
--   fromProto =
--     Msat . from . unProtoVal

unProtoVal ::
  forall proto hs.
  ( HasField proto "val" hs
  ) =>
  proto ->
  hs
unProtoVal =
  (^. field @"val")
