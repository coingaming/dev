{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module BtcLsp.Instance.WitchOrphan () where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import Lens.Micro
import qualified LndClient as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Data.LowLevel as Proto
import qualified Witch

--
-- TODO : smart constuctors are needed!!!
--

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
    & field @"val" .~ (from x)

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
      & Proto.val .~ (coerce x)

instance From Text Lnd.PaymentRequest

instance From Lnd.PaymentRequest Text

instance From Proto.LnInvoice (LnInvoice tdir) where
  from =
    via @Lnd.PaymentRequest . (^. Proto.val)

instance From (LnInvoice tdir) Proto.LnInvoice where
  from x =
    defMessage
      & Proto.val .~ (via @Lnd.PaymentRequest x)

instance From Proto.FundLnInvoice (LnInvoice 'Fund) where
  from = fromProto

instance From (LnInvoice 'Fund) Proto.FundLnInvoice where
  from = intoProto

instance From Proto.OnChainAddress (OnChainAddress tdir) where
  from = fromProto

instance From (OnChainAddress tdir) Proto.OnChainAddress where
  from = intoProto

instance From Proto.RefundOnChainAddress (OnChainAddress 'Refund) where
  from = fromProto

instance From (OnChainAddress 'Refund) Proto.RefundOnChainAddress where
  from = intoProto
