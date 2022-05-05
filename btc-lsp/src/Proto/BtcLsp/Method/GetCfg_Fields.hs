{- This file was auto-generated from btc_lsp/method/get_cfg.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Method.GetCfg_Fields where
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
import qualified Proto.BtcLsp.Data.HighLevel
ctx ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "ctx" a) =>
  Lens.Family2.LensLike' f s a
ctx = Data.ProtoLens.Field.field @"ctx"
failure ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "failure" a) =>
  Lens.Family2.LensLike' f s a
failure = Data.ProtoLens.Field.field @"failure"
generic ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "generic" a) =>
  Lens.Family2.LensLike' f s a
generic = Data.ProtoLens.Field.field @"generic"
internal ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "internal" a) =>
  Lens.Family2.LensLike' f s a
internal = Data.ProtoLens.Field.field @"internal"
lspLnNodes ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "lspLnNodes" a) =>
  Lens.Family2.LensLike' f s a
lspLnNodes = Data.ProtoLens.Field.field @"lspLnNodes"
maybe'ctx ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'ctx" a) =>
  Lens.Family2.LensLike' f s a
maybe'ctx = Data.ProtoLens.Field.field @"maybe'ctx"
maybe'either ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'either" a) =>
  Lens.Family2.LensLike' f s a
maybe'either = Data.ProtoLens.Field.field @"maybe'either"
maybe'failure ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'failure" a) =>
  Lens.Family2.LensLike' f s a
maybe'failure = Data.ProtoLens.Field.field @"maybe'failure"
maybe'success ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'success" a) =>
  Lens.Family2.LensLike' f s a
maybe'success = Data.ProtoLens.Field.field @"maybe'success"
maybe'swapFromLnMaxAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapFromLnMaxAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapFromLnMaxAmt
  = Data.ProtoLens.Field.field @"maybe'swapFromLnMaxAmt"
maybe'swapFromLnMinAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapFromLnMinAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapFromLnMinAmt
  = Data.ProtoLens.Field.field @"maybe'swapFromLnMinAmt"
maybe'swapIntoLnMaxAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapIntoLnMaxAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapIntoLnMaxAmt
  = Data.ProtoLens.Field.field @"maybe'swapIntoLnMaxAmt"
maybe'swapIntoLnMinAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapIntoLnMinAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapIntoLnMinAmt
  = Data.ProtoLens.Field.field @"maybe'swapIntoLnMinAmt"
maybe'swapLnFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapLnFeeRate" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapLnFeeRate
  = Data.ProtoLens.Field.field @"maybe'swapLnFeeRate"
maybe'swapLnMinFee ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'swapLnMinFee" a) =>
  Lens.Family2.LensLike' f s a
maybe'swapLnMinFee
  = Data.ProtoLens.Field.field @"maybe'swapLnMinFee"
specific ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "specific" a) =>
  Lens.Family2.LensLike' f s a
specific = Data.ProtoLens.Field.field @"specific"
success ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "success" a) =>
  Lens.Family2.LensLike' f s a
success = Data.ProtoLens.Field.field @"success"
swapFromLnMaxAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapFromLnMaxAmt" a) =>
  Lens.Family2.LensLike' f s a
swapFromLnMaxAmt = Data.ProtoLens.Field.field @"swapFromLnMaxAmt"
swapFromLnMinAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapFromLnMinAmt" a) =>
  Lens.Family2.LensLike' f s a
swapFromLnMinAmt = Data.ProtoLens.Field.field @"swapFromLnMinAmt"
swapIntoLnMaxAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapIntoLnMaxAmt" a) =>
  Lens.Family2.LensLike' f s a
swapIntoLnMaxAmt = Data.ProtoLens.Field.field @"swapIntoLnMaxAmt"
swapIntoLnMinAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapIntoLnMinAmt" a) =>
  Lens.Family2.LensLike' f s a
swapIntoLnMinAmt = Data.ProtoLens.Field.field @"swapIntoLnMinAmt"
swapLnFeeRate ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapLnFeeRate" a) =>
  Lens.Family2.LensLike' f s a
swapLnFeeRate = Data.ProtoLens.Field.field @"swapLnFeeRate"
swapLnMinFee ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "swapLnMinFee" a) =>
  Lens.Family2.LensLike' f s a
swapLnMinFee = Data.ProtoLens.Field.field @"swapLnMinFee"
vec'generic ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'generic" a) =>
  Lens.Family2.LensLike' f s a
vec'generic = Data.ProtoLens.Field.field @"vec'generic"
vec'internal ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'internal" a) =>
  Lens.Family2.LensLike' f s a
vec'internal = Data.ProtoLens.Field.field @"vec'internal"
vec'lspLnNodes ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'lspLnNodes" a) =>
  Lens.Family2.LensLike' f s a
vec'lspLnNodes = Data.ProtoLens.Field.field @"vec'lspLnNodes"
vec'specific ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'specific" a) =>
  Lens.Family2.LensLike' f s a
vec'specific = Data.ProtoLens.Field.field @"vec'specific"