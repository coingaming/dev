{- This file was auto-generated from btc_lsp/custody/open_chan_on_chain.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Custody.OpenChanOnChain_Fields where
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
import qualified Proto.BtcLsp.Type
connectToNode ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "connectToNode" a) =>
  Lens.Family2.LensLike' f s a
connectToNode = Data.ProtoLens.Field.field @"connectToNode"
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
input ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "input" a) =>
  Lens.Family2.LensLike' f s a
input = Data.ProtoLens.Field.field @"input"
internal ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "internal" a) =>
  Lens.Family2.LensLike' f s a
internal = Data.ProtoLens.Field.field @"internal"
localBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "localBalance" a) =>
  Lens.Family2.LensLike' f s a
localBalance = Data.ProtoLens.Field.field @"localBalance"
maybe'connectToNode ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'connectToNode" a) =>
  Lens.Family2.LensLike' f s a
maybe'connectToNode
  = Data.ProtoLens.Field.field @"maybe'connectToNode"
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
maybe'localBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'localBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'localBalance
  = Data.ProtoLens.Field.field @"maybe'localBalance"
maybe'payFundingAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'payFundingAddress" a) =>
  Lens.Family2.LensLike' f s a
maybe'payFundingAddress
  = Data.ProtoLens.Field.field @"maybe'payFundingAddress"
maybe'payFundingAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'payFundingAmt" a) =>
  Lens.Family2.LensLike' f s a
maybe'payFundingAmt
  = Data.ProtoLens.Field.field @"maybe'payFundingAmt"
maybe'remoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'remoteBalance" a) =>
  Lens.Family2.LensLike' f s a
maybe'remoteBalance
  = Data.ProtoLens.Field.field @"maybe'remoteBalance"
maybe'success ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "maybe'success" a) =>
  Lens.Family2.LensLike' f s a
maybe'success = Data.ProtoLens.Field.field @"maybe'success"
payFundingAddress ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "payFundingAddress" a) =>
  Lens.Family2.LensLike' f s a
payFundingAddress = Data.ProtoLens.Field.field @"payFundingAddress"
payFundingAmt ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "payFundingAmt" a) =>
  Lens.Family2.LensLike' f s a
payFundingAmt = Data.ProtoLens.Field.field @"payFundingAmt"
remoteBalance ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "remoteBalance" a) =>
  Lens.Family2.LensLike' f s a
remoteBalance = Data.ProtoLens.Field.field @"remoteBalance"
success ::
  forall f s a.
  (Prelude.Functor f, Data.ProtoLens.Field.HasField s "success" a) =>
  Lens.Family2.LensLike' f s a
success = Data.ProtoLens.Field.field @"success"
vec'input ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'input" a) =>
  Lens.Family2.LensLike' f s a
vec'input = Data.ProtoLens.Field.field @"vec'input"
vec'internal ::
  forall f s a.
  (Prelude.Functor f,
   Data.ProtoLens.Field.HasField s "vec'internal" a) =>
  Lens.Family2.LensLike' f s a
vec'internal = Data.ProtoLens.Field.field @"vec'internal"