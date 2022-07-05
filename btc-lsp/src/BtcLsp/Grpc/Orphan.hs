{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Grpc.Orphan () where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Data.Type
import BtcLsp.Import.External
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import qualified LndClient as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Data.LowLevel as Proto
import qualified Proto.BtcLsp.Data.LowLevel_Fields as LowLevel
import qualified Witch

fromProto ::
  forall proto through haskell.
  ( HasField proto "val" through,
    From through haskell,
    'False ~ (through == haskell)
  ) =>
  proto ->
  haskell
fromProto =
  from
    . (^. field @"val")

intoProto ::
  forall proto through haskell.
  ( Message proto,
    HasField proto "val" through,
    From haskell through,
    'False ~ (haskell == through)
  ) =>
  haskell ->
  proto
intoProto x =
  defMessage
    & field @"val" .~ from x

instance From Proto.Nonce Nonce where
  from = fromProto

instance From Nonce Proto.Nonce where
  from = intoProto

instance From Proto.LnPubKey NodePubKey where
  from =
    coerce . (^. Proto.val)

instance From NodePubKey Proto.LnPubKey where
  from x =
    defMessage
      & Proto.val .~ coerce x

instance From Proto.LnInvoice (LnInvoice mrel) where
  from =
    via @Lnd.PaymentRequest . (^. Proto.val)

instance From (LnInvoice mrel) Proto.LnInvoice where
  from x =
    defMessage
      & Proto.val .~ via @Lnd.PaymentRequest x

instance From Proto.FundLnInvoice (LnInvoice 'Fund) where
  from = fromProto

instance From (LnInvoice 'Fund) Proto.FundLnInvoice where
  from = intoProto

instance From Proto.OnChainAddress (OnChainAddress mrel) where
  from = fromProto

instance From (OnChainAddress mrel) Proto.OnChainAddress where
  from = intoProto

instance From Proto.OnChainAddress Text where
  from = (^. field @"val")

instance From Proto.RefundOnChainAddress Text where
  from = fromProto

instance From (OnChainAddress 'Refund) Proto.RefundOnChainAddress where
  from = intoProto

instance From Proto.FundOnChainAddress (OnChainAddress 'Fund) where
  from = fromProto

instance From (OnChainAddress 'Fund) Proto.FundOnChainAddress where
  from = intoProto

instance From Proto.Privacy Privacy where
  from = toEnum . fromEnum

instance From Privacy Proto.Privacy where
  from = toEnum . fromEnum

instance From Proto.Msat MSat where
  from = fromProto

instance From MSat Proto.Msat where
  from = intoProto

instance From Proto.FundMoney MSat where
  from = fromProto

instance From MSat Proto.FundMoney where
  from = intoProto

deriving stock instance Eq CompressMode

deriving stock instance Generic CompressMode

instance FromJSON CompressMode

instance From PortNumber Word32 where
  from = fromIntegral -- Word16 to Word32 is fine.

instance From PortNumber Proto.LnPort where
  from = intoProto

instance From HostName Proto.LnHost where
  from = intoProto

instance From (Money owner btcl mrel) Proto.Msat where
  from = intoProto

instance From (Money 'Usr btcl 'Fund) Proto.LocalBalance where
  from = intoProto

instance From (Money 'Lsp btcl 'Gain) Proto.FeeMoney where
  from = intoProto

instance From FeeRate Proto.Urational where
  from (FeeRate x) =
    defMessage
      & LowLevel.numerator .~ numerator x
      & LowLevel.denominator .~ denominator x

instance From FeeRate Proto.FeeRate where
  from = intoProto
