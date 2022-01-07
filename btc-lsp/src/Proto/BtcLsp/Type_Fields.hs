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
max ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "max" a) =>
  Lens.Family2.LensLike' f s a
max = Data.ProtoLens.Field.field @"max"
maybe'lnPubKey ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'lnPubKey" a) =>
  Lens.Family2.LensLike' f s a
maybe'lnPubKey = Data.ProtoLens.Field.field @"maybe'lnPubKey"
maybe'max ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'max" a) =>
  Lens.Family2.LensLike' f s a
maybe'max = Data.ProtoLens.Field.field @"maybe'max"
maybe'min ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'min" a) =>
  Lens.Family2.LensLike' f s a
maybe'min = Data.ProtoLens.Field.field @"maybe'min"
maybe'nonce ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'nonce" a) =>
  Lens.Family2.LensLike' f s a
maybe'nonce = Data.ProtoLens.Field.field @"maybe'nonce"
maybe'openChanFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanFeeRate" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanFeeRate
  = Data.ProtoLens.Field.field @"maybe'openChanFeeRate"
maybe'openChanLnLimit ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanLnLimit" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanLnLimit
  = Data.ProtoLens.Field.field @"maybe'openChanLnLimit"
maybe'openChanMinFee ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanMinFee" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanMinFee
  = Data.ProtoLens.Field.field @"maybe'openChanMinFee"
maybe'openChanOnChainLimit ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'openChanOnChainLimit" a) =>
  Lens.Family2.LensLike' f s a
maybe'openChanOnChainLimit
  = Data.ProtoLens.Field.field @"maybe'openChanOnChainLimit"
maybe'val ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'val" a) =>
  Lens.Family2.LensLike' f s a
maybe'val = Data.ProtoLens.Field.field @"maybe'val"
min ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "min" a) =>
  Lens.Family2.LensLike' f s a
min = Data.ProtoLens.Field.field @"min"
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
openChanFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanFeeRate" a) =>
  Lens.Family2.LensLike' f s a
openChanFeeRate = Data.ProtoLens.Field.field @"openChanFeeRate"
openChanLnLimit ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanLnLimit" a) =>
  Lens.Family2.LensLike' f s a
openChanLnLimit = Data.ProtoLens.Field.field @"openChanLnLimit"
openChanMinFee ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanMinFee" a) =>
  Lens.Family2.LensLike' f s a
openChanMinFee = Data.ProtoLens.Field.field @"openChanMinFee"
openChanOnChainLimit ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "openChanOnChainLimit" a) =>
  Lens.Family2.LensLike' f s a
openChanOnChainLimit
  = Data.ProtoLens.Field.field @"openChanOnChainLimit"
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