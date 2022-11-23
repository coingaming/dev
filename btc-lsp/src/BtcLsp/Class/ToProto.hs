module BtcLsp.Class.ToProto
  ( ToProto (..),
    newProtoVal,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Orphan ()
import BtcLsp.Data.Type
import BtcLsp.Import.External
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import qualified LndClient as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.LowLevel as Proto
import qualified Proto.BtcLsp.Data.LowLevel_Fields as LowLevel

class ('False ~ (haskell == proto)) => ToProto haskell proto where
  toProto :: haskell -> proto

instance ToProto Nonce Proto.Nonce where
  toProto =
    newProtoVal
      . unNonce

instance ToProto NodePubKey Proto.LnPubKey where
  toProto =
    newProtoVal
      . unNodePubKey

instance ToProto Lnd.PaymentRequest Proto.LnInvoice where
  toProto =
    newProtoVal
      . Lnd.unPaymentRequest

instance ToProto (LnInvoice 'Fund) Proto.FundLnInvoice where
  toProto =
    newProtoVal
      . toProto @Lnd.PaymentRequest @Proto.LnInvoice
      . unLnInvoice

instance ToProto Msat Proto.Msat where
  toProto =
    newProtoVal
      . unsafeFrom @Natural @Word64
      . unMsat

instance ToProto (Money 'Usr 'OnChain 'Fund) Proto.FundMoney where
  toProto =
    newProtoVal
      . toProto @Msat @Proto.Msat
      . unMoney

instance ToProto PortNumber Proto.LnPort where
  toProto =
    newProtoVal
      . fromIntegral -- Word16 to Word32 is fine

instance ToProto HostName Proto.LnHost where
  toProto =
    newProtoVal
      . pack

instance ToProto (Money 'Usr btcl 'Fund) Proto.LocalBalance where
  toProto =
    newProtoVal
      . toProto @Msat @Proto.Msat
      . unMoney

instance ToProto (Money 'Lsp btcl 'Gain) Proto.FeeMoney where
  toProto =
    newProtoVal
      . toProto @Msat @Proto.Msat
      . unMoney

instance ToProto (Ratio Natural) Proto.Urational where
  toProto x =
    defMessage
      & LowLevel.numerator
        .~ unsafeFrom @Natural @Word64 (numerator x)
      & LowLevel.denominator
        .~ unsafeFrom @Natural @Word64 (denominator x)

instance ToProto FeeRate Proto.FeeRate where
  toProto =
    newProtoVal
      . toProto @(Ratio Natural) @Proto.Urational
      . unFeeRate

newProtoVal ::
  forall field proto.
  ( Message proto,
    HasField proto "val" field
  ) =>
  field ->
  proto
newProtoVal x =
  defMessage
    & field @"val" .~ x
