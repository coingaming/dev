{- This file was auto-generated from btc_lsp/type.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Type_Fields where
import qualified Data.ProtoLens.Runtime.Prelude as Prelude
import qualified Data.ProtoLens.Runtime.Data.Int as Data.Int
import qualified Data.ProtoLens.Runtime.Data.Monoid as Data.Monoid
import qualified Data.ProtoLens.Runtime.Data.Word as Data.Word
import qualified Data.ProtoLens.Runtime.Data.ProtoLens as Data.ProtoLens
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Bytes as Data.ProtoLens.Encoding.Bytes
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Growing as Data.ProtoLens.Encoding.Growing
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Parser.Unsafe as Data.ProtoLens.Encoding.Parser.Unsafe
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Encoding.Wire as Data.ProtoLens.Encoding.Wire
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Field as Data.ProtoLens.Field
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Message.Enum as Data.ProtoLens.Message.Enum
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Service.Types as Data.ProtoLens.Service.Types
import qualified Data.ProtoLens.Runtime.Lens.Family2 as Lens.Family2
import qualified Data.ProtoLens.Runtime.Lens.Family2.Unchecked as Lens.Family2.Unchecked
import qualified Data.ProtoLens.Runtime.Data.Text as Data.Text
import qualified Data.ProtoLens.Runtime.Data.Map as Data.Map
import qualified Data.ProtoLens.Runtime.Data.ByteString as Data.ByteString
import qualified Data.ProtoLens.Runtime.Data.ByteString.Char8 as Data.ByteString.Char8
import qualified Data.ProtoLens.Runtime.Data.Text.Encoding as Data.Text.Encoding
import qualified Data.ProtoLens.Runtime.Data.Vector as Data.Vector
import qualified Data.ProtoLens.Runtime.Data.Vector.Generic as Data.Vector.Generic
import qualified Data.ProtoLens.Runtime.Data.Vector.Unboxed as Data.Vector.Unboxed
import qualified Data.ProtoLens.Runtime.Text.Read as Text.Read
import qualified Proto.BtcLsp.Newtype
denominator ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "denominator" a) =>
  Lens.Family2.LensLike' f s a
denominator = Data.ProtoLens.Field.field @"denominator"
fieldLocation ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "fieldLocation" a) =>
  Lens.Family2.LensLike' f s a
fieldLocation = Data.ProtoLens.Field.field @"fieldLocation"
kind ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "kind" a) =>
  Lens.Family2.LensLike' f s a
kind = Data.ProtoLens.Field.field @"kind"
lnPubKey ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "lnPubKey" a) =>
  Lens.Family2.LensLike' f s a
lnPubKey = Data.ProtoLens.Field.field @"lnPubKey"
maybe'lnPubKey ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'lnPubKey" a) =>
  Lens.Family2.LensLike' f s a
maybe'lnPubKey = Data.ProtoLens.Field.field @"maybe'lnPubKey"
maybe'nonce ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'nonce" a) =>
  Lens.Family2.LensLike' f s a
maybe'nonce = Data.ProtoLens.Field.field @"maybe'nonce"
maybe'openChanMaxLocalBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMaxLocalBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMaxLocalBalance
  = Data.ProtoLens.Field.field @"maybe'openChanMaxLocalBalance"
maybe'openChanMaxRemoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMaxRemoteBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMaxRemoteBalance
  = Data.ProtoLens.Field.field @"maybe'openChanMaxRemoteBalance"
maybe'openChanMinFeeAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMinFeeAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMinFeeAmt
  = Data.ProtoLens.Field.field @"maybe'openChanMinFeeAmt"
maybe'openChanMinLocalBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMinLocalBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMinLocalBalance
  = Data.ProtoLens.Field.field @"maybe'openChanMinLocalBalance"
maybe'openChanMinRemoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMinRemoteBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMinRemoteBalance
  = Data.ProtoLens.Field.field @"maybe'openChanMinRemoteBalance"
maybe'openChanRemoteBalanceFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanRemoteBalanceFeeRate" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanRemoteBalanceFeeRate
  = Data.ProtoLens.Field.field @"maybe'openChanRemoteBalanceFeeRate"
maybe'val ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'val" a) =>
  Lens.Family2.LensLike' f s a
maybe'val = Data.ProtoLens.Field.field @"maybe'val"
negative ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "negative" a) =>
  Lens.Family2.LensLike' f s a
negative = Data.ProtoLens.Field.field @"negative"
nonce ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "nonce" a) =>
  Lens.Family2.LensLike' f s a
nonce = Data.ProtoLens.Field.field @"nonce"
numerator ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "numerator" a) =>
  Lens.Family2.LensLike' f s a
numerator = Data.ProtoLens.Field.field @"numerator"
openChanMaxLocalBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMaxLocalBalance" a) =>
  Lens.Family2.LensLike' f s a
openChanMaxLocalBalance
  = Data.ProtoLens.Field.field @"openChanMaxLocalBalance"
openChanMaxRemoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMaxRemoteBalance" a) =>
  Lens.Family2.LensLike' f s a
openChanMaxRemoteBalance
  = Data.ProtoLens.Field.field @"openChanMaxRemoteBalance"
openChanMinFeeAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMinFeeAmt" a) =>
  Lens.Family2.LensLike' f s a
openChanMinFeeAmt = Data.ProtoLens.Field.field @"openChanMinFeeAmt"
openChanMinLocalBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMinLocalBalance" a) =>
  Lens.Family2.LensLike' f s a
openChanMinLocalBalance
  = Data.ProtoLens.Field.field @"openChanMinLocalBalance"
openChanMinRemoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMinRemoteBalance" a) =>
  Lens.Family2.LensLike' f s a
openChanMinRemoteBalance
  = Data.ProtoLens.Field.field @"openChanMinRemoteBalance"
openChanRemoteBalanceFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanRemoteBalanceFeeRate" a) =>
  Lens.Family2.LensLike' f s a
openChanRemoteBalanceFeeRate
  = Data.ProtoLens.Field.field @"openChanRemoteBalanceFeeRate"
val ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "val" a) =>
  Lens.Family2.LensLike' f s a
val = Data.ProtoLens.Field.field @"val"
vec'fieldLocation ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'fieldLocation" a) =>
  Lens.Family2.LensLike' f s a
vec'fieldLocation = Data.ProtoLens.Field.field @"vec'fieldLocation"