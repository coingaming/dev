{- This file was auto-generated from btc_lsp/data/high_level.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Data.HighLevel (
        Ctx(), FeeAmt(), FeeRate(), FieldIndex(), FundAmt(),
        FundLnHodlInvoice(), FundLnInvoice(), FundOnChainAddress(),
        InputFailure(), InputFailureKind(..), InputFailureKind(),
        InputFailureKind'UnrecognizedValue, LnPubKey(), LocalBalance(),
        LspLnSocketAddress(), Nonce(), RefundAmt(), RefundOnChainAddress(),
        RemoteBalance()
    ) where
import qualified Data.ProtoLens.Runtime.Control.DeepSeq as Control.DeepSeq
import qualified Data.ProtoLens.Runtime.Data.ProtoLens.Prism as Data.ProtoLens.Prism
import qualified Text.PrettyPrint.GenericPretty.Instance
import qualified GHC.Generics
import qualified Text.PrettyPrint.GenericPretty
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
import qualified Proto.BtcLsp.Data.LowLevel
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.nonce' @:: Lens' Ctx Nonce@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'nonce' @:: Lens' Ctx (Prelude.Maybe Nonce)@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.lnPubKey' @:: Lens' Ctx LnPubKey@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'lnPubKey' @:: Lens' Ctx (Prelude.Maybe LnPubKey)@ -}
data Ctx
  = Ctx'_constructor {_Ctx'nonce :: !(Prelude.Maybe Nonce),
                      _Ctx'lnPubKey :: !(Prelude.Maybe LnPubKey),
                      _Ctx'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Ctx where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Ctx
instance Data.ProtoLens.Field.HasField Ctx "nonce" Nonce where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'nonce" (Prelude.Maybe Nonce) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Ctx "lnPubKey" LnPubKey where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'lnPubKey (\ x__ y__ -> x__ {_Ctx'lnPubKey = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'lnPubKey" (Prelude.Maybe LnPubKey) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'lnPubKey (\ x__ y__ -> x__ {_Ctx'lnPubKey = y__}))
        Prelude.id
instance Data.ProtoLens.Message Ctx where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.Ctx"
  packedMessageDescriptor _
    = "\n\
      \\ETXCtx\DC22\n\
      \\ENQnonce\CAN\SOH \SOH(\v2\FS.BtcLsp.Data.HighLevel.NonceR\ENQnonce\DC2=\n\
      \\n\
      \ln_pub_key\CAN\STX \SOH(\v2\US.BtcLsp.Data.HighLevel.LnPubKeyR\blnPubKey"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nonce__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "nonce"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Nonce)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'nonce")) ::
              Data.ProtoLens.FieldDescriptor Ctx
        lnPubKey__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ln_pub_key"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor LnPubKey)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'lnPubKey")) ::
              Data.ProtoLens.FieldDescriptor Ctx
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, nonce__field_descriptor),
           (Data.ProtoLens.Tag 2, lnPubKey__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Ctx'_unknownFields (\ x__ y__ -> x__ {_Ctx'_unknownFields = y__})
  defMessage
    = Ctx'_constructor
        {_Ctx'nonce = Prelude.Nothing, _Ctx'lnPubKey = Prelude.Nothing,
         _Ctx'_unknownFields = []}
  parseMessage
    = let
        loop :: Ctx -> Data.ProtoLens.Encoding.Bytes.Parser Ctx
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "nonce"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"nonce") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "ln_pub_key"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"lnPubKey") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Ctx"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'nonce") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'lnPubKey") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage
                             _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Ctx where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Ctx'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Ctx'nonce x__) (Control.DeepSeq.deepseq (_Ctx'lnPubKey x__) ()))
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FeeAmt Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FeeAmt (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data FeeAmt
  = FeeAmt'_constructor {_FeeAmt'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                         _FeeAmt'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FeeAmt where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FeeAmt
instance Data.ProtoLens.Field.HasField FeeAmt "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeAmt'val (\ x__ y__ -> x__ {_FeeAmt'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FeeAmt "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeAmt'val (\ x__ y__ -> x__ {_FeeAmt'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FeeAmt where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FeeAmt"
  packedMessageDescriptor _
    = "\n\
      \\ACKFeeAmt\DC2,\n\
      \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FeeAmt
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FeeAmt'_unknownFields
        (\ x__ y__ -> x__ {_FeeAmt'_unknownFields = y__})
  defMessage
    = FeeAmt'_constructor
        {_FeeAmt'val = Prelude.Nothing, _FeeAmt'_unknownFields = []}
  parseMessage
    = let
        loop :: FeeAmt -> Data.ProtoLens.Encoding.Bytes.Parser FeeAmt
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FeeAmt"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FeeAmt where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FeeAmt'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FeeAmt'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FeeRate Proto.BtcLsp.Data.LowLevel.Urational@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FeeRate (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Urational)@ -}
data FeeRate
  = FeeRate'_constructor {_FeeRate'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Urational),
                          _FeeRate'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FeeRate where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FeeRate
instance Data.ProtoLens.Field.HasField FeeRate "val" Proto.BtcLsp.Data.LowLevel.Urational where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeRate'val (\ x__ y__ -> x__ {_FeeRate'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FeeRate "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Urational) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeRate'val (\ x__ y__ -> x__ {_FeeRate'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FeeRate where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FeeRate"
  packedMessageDescriptor _
    = "\n\
      \\aFeeRate\DC21\n\
      \\ETXval\CAN\SOH \SOH(\v2\US.BtcLsp.Data.LowLevel.UrationalR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Urational)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FeeRate
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FeeRate'_unknownFields
        (\ x__ y__ -> x__ {_FeeRate'_unknownFields = y__})
  defMessage
    = FeeRate'_constructor
        {_FeeRate'val = Prelude.Nothing, _FeeRate'_unknownFields = []}
  parseMessage
    = let
        loop :: FeeRate -> Data.ProtoLens.Encoding.Bytes.Parser FeeRate
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FeeRate"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FeeRate where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FeeRate'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FeeRate'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FieldIndex Data.Word.Word32@ -}
data FieldIndex
  = FieldIndex'_constructor {_FieldIndex'val :: !Data.Word.Word32,
                             _FieldIndex'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FieldIndex where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FieldIndex
instance Data.ProtoLens.Field.HasField FieldIndex "val" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FieldIndex'val (\ x__ y__ -> x__ {_FieldIndex'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FieldIndex where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FieldIndex"
  packedMessageDescriptor _
    = "\n\
      \\n\
      \FieldIndex\DC2\DLE\n\
      \\ETXval\CAN\SOH \SOH(\rR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt32Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word32)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"val")) ::
              Data.ProtoLens.FieldDescriptor FieldIndex
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FieldIndex'_unknownFields
        (\ x__ y__ -> x__ {_FieldIndex'_unknownFields = y__})
  defMessage
    = FieldIndex'_constructor
        {_FieldIndex'val = Data.ProtoLens.fieldDefault,
         _FieldIndex'_unknownFields = []}
  parseMessage
    = let
        loop ::
          FieldIndex -> Data.ProtoLens.Encoding.Bytes.Parser FieldIndex
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.fromIntegral
                                          Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FieldIndex"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"val") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FieldIndex where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FieldIndex'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FieldIndex'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FundAmt Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FundAmt (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data FundAmt
  = FundAmt'_constructor {_FundAmt'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                          _FundAmt'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FundAmt where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FundAmt
instance Data.ProtoLens.Field.HasField FundAmt "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundAmt'val (\ x__ y__ -> x__ {_FundAmt'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FundAmt "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundAmt'val (\ x__ y__ -> x__ {_FundAmt'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FundAmt where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FundAmt"
  packedMessageDescriptor _
    = "\n\
      \\aFundAmt\DC2,\n\
      \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FundAmt
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FundAmt'_unknownFields
        (\ x__ y__ -> x__ {_FundAmt'_unknownFields = y__})
  defMessage
    = FundAmt'_constructor
        {_FundAmt'val = Prelude.Nothing, _FundAmt'_unknownFields = []}
  parseMessage
    = let
        loop :: FundAmt -> Data.ProtoLens.Encoding.Bytes.Parser FundAmt
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FundAmt"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundAmt where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundAmt'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundAmt'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FundLnHodlInvoice Proto.BtcLsp.Data.LowLevel.LnHodlInvoice@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FundLnHodlInvoice (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnHodlInvoice)@ -}
data FundLnHodlInvoice
  = FundLnHodlInvoice'_constructor {_FundLnHodlInvoice'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnHodlInvoice),
                                    _FundLnHodlInvoice'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FundLnHodlInvoice where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FundLnHodlInvoice
instance Data.ProtoLens.Field.HasField FundLnHodlInvoice "val" Proto.BtcLsp.Data.LowLevel.LnHodlInvoice where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundLnHodlInvoice'val
           (\ x__ y__ -> x__ {_FundLnHodlInvoice'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FundLnHodlInvoice "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnHodlInvoice) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundLnHodlInvoice'val
           (\ x__ y__ -> x__ {_FundLnHodlInvoice'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FundLnHodlInvoice where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.FundLnHodlInvoice"
  packedMessageDescriptor _
    = "\n\
      \\DC1FundLnHodlInvoice\DC25\n\
      \\ETXval\CAN\SOH \SOH(\v2#.BtcLsp.Data.LowLevel.LnHodlInvoiceR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.LnHodlInvoice)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FundLnHodlInvoice
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FundLnHodlInvoice'_unknownFields
        (\ x__ y__ -> x__ {_FundLnHodlInvoice'_unknownFields = y__})
  defMessage
    = FundLnHodlInvoice'_constructor
        {_FundLnHodlInvoice'val = Prelude.Nothing,
         _FundLnHodlInvoice'_unknownFields = []}
  parseMessage
    = let
        loop ::
          FundLnHodlInvoice
          -> Data.ProtoLens.Encoding.Bytes.Parser FundLnHodlInvoice
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FundLnHodlInvoice"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundLnHodlInvoice where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundLnHodlInvoice'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundLnHodlInvoice'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FundLnInvoice Proto.BtcLsp.Data.LowLevel.LnInvoice@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FundLnInvoice (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnInvoice)@ -}
data FundLnInvoice
  = FundLnInvoice'_constructor {_FundLnInvoice'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnInvoice),
                                _FundLnInvoice'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FundLnInvoice where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FundLnInvoice
instance Data.ProtoLens.Field.HasField FundLnInvoice "val" Proto.BtcLsp.Data.LowLevel.LnInvoice where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundLnInvoice'val (\ x__ y__ -> x__ {_FundLnInvoice'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FundLnInvoice "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.LnInvoice) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundLnInvoice'val (\ x__ y__ -> x__ {_FundLnInvoice'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FundLnInvoice where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.FundLnInvoice"
  packedMessageDescriptor _
    = "\n\
      \\rFundLnInvoice\DC21\n\
      \\ETXval\CAN\SOH \SOH(\v2\US.BtcLsp.Data.LowLevel.LnInvoiceR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.LnInvoice)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FundLnInvoice
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FundLnInvoice'_unknownFields
        (\ x__ y__ -> x__ {_FundLnInvoice'_unknownFields = y__})
  defMessage
    = FundLnInvoice'_constructor
        {_FundLnInvoice'val = Prelude.Nothing,
         _FundLnInvoice'_unknownFields = []}
  parseMessage
    = let
        loop ::
          FundLnInvoice -> Data.ProtoLens.Encoding.Bytes.Parser FundLnInvoice
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FundLnInvoice"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundLnInvoice where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundLnInvoice'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundLnInvoice'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FundOnChainAddress Proto.BtcLsp.Data.LowLevel.OnChainAddress@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FundOnChainAddress (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress)@ -}
data FundOnChainAddress
  = FundOnChainAddress'_constructor {_FundOnChainAddress'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress),
                                     _FundOnChainAddress'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FundOnChainAddress where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FundOnChainAddress
instance Data.ProtoLens.Field.HasField FundOnChainAddress "val" Proto.BtcLsp.Data.LowLevel.OnChainAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundOnChainAddress'val
           (\ x__ y__ -> x__ {_FundOnChainAddress'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FundOnChainAddress "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundOnChainAddress'val
           (\ x__ y__ -> x__ {_FundOnChainAddress'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FundOnChainAddress where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.FundOnChainAddress"
  packedMessageDescriptor _
    = "\n\
      \\DC2FundOnChainAddress\DC26\n\
      \\ETXval\CAN\SOH \SOH(\v2$.BtcLsp.Data.LowLevel.OnChainAddressR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.OnChainAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor FundOnChainAddress
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FundOnChainAddress'_unknownFields
        (\ x__ y__ -> x__ {_FundOnChainAddress'_unknownFields = y__})
  defMessage
    = FundOnChainAddress'_constructor
        {_FundOnChainAddress'val = Prelude.Nothing,
         _FundOnChainAddress'_unknownFields = []}
  parseMessage
    = let
        loop ::
          FundOnChainAddress
          -> Data.ProtoLens.Encoding.Bytes.Parser FundOnChainAddress
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "FundOnChainAddress"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundOnChainAddress where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundOnChainAddress'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundOnChainAddress'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.fieldLocation' @:: Lens' InputFailure [FieldIndex]@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.vec'fieldLocation' @:: Lens' InputFailure (Data.Vector.Vector FieldIndex)@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.kind' @:: Lens' InputFailure InputFailureKind@ -}
data InputFailure
  = InputFailure'_constructor {_InputFailure'fieldLocation :: !(Data.Vector.Vector FieldIndex),
                               _InputFailure'kind :: !InputFailureKind,
                               _InputFailure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show InputFailure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out InputFailure
instance Data.ProtoLens.Field.HasField InputFailure "fieldLocation" [FieldIndex] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InputFailure "vec'fieldLocation" (Data.Vector.Vector FieldIndex) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InputFailure "kind" InputFailureKind where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'kind (\ x__ y__ -> x__ {_InputFailure'kind = y__}))
        Prelude.id
instance Data.ProtoLens.Message InputFailure where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.InputFailure"
  packedMessageDescriptor _
    = "\n\
      \\fInputFailure\DC2H\n\
      \\SOfield_location\CAN\SOH \ETX(\v2!.BtcLsp.Data.HighLevel.FieldIndexR\rfieldLocation\DC2;\n\
      \\EOTkind\CAN\STX \SOH(\SO2'.BtcLsp.Data.HighLevel.InputFailureKindR\EOTkind"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fieldLocation__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "field_location"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor FieldIndex)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"fieldLocation")) ::
              Data.ProtoLens.FieldDescriptor InputFailure
        kind__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "kind"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor InputFailureKind)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"kind")) ::
              Data.ProtoLens.FieldDescriptor InputFailure
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, fieldLocation__field_descriptor),
           (Data.ProtoLens.Tag 2, kind__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _InputFailure'_unknownFields
        (\ x__ y__ -> x__ {_InputFailure'_unknownFields = y__})
  defMessage
    = InputFailure'_constructor
        {_InputFailure'fieldLocation = Data.Vector.Generic.empty,
         _InputFailure'kind = Data.ProtoLens.fieldDefault,
         _InputFailure'_unknownFields = []}
  parseMessage
    = let
        loop ::
          InputFailure
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld FieldIndex
             -> Data.ProtoLens.Encoding.Bytes.Parser InputFailure
        loop x mutable'fieldLocation
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'fieldLocation <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                                   mutable'fieldLocation)
                      (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields
                           (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'fieldLocation")
                              frozen'fieldLocation
                              x))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "field_location"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append
                                          mutable'fieldLocation y)
                                loop x v
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "kind"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"kind") y x)
                                  mutable'fieldLocation
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'fieldLocation
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'fieldLocation <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                         Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'fieldLocation)
          "InputFailure"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                (\ _v
                   -> (Data.Monoid.<>)
                        (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                        ((Prelude..)
                           (\ bs
                              -> (Data.Monoid.<>)
                                   (Data.ProtoLens.Encoding.Bytes.putVarInt
                                      (Prelude.fromIntegral (Data.ByteString.length bs)))
                                   (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                           Data.ProtoLens.encodeMessage
                           _v))
                (Lens.Family2.view
                   (Data.ProtoLens.Field.field @"vec'fieldLocation") _x))
             ((Data.Monoid.<>)
                (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"kind") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         ((Prelude..)
                            ((Prelude..)
                               Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                            Prelude.fromEnum
                            _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData InputFailure where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_InputFailure'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_InputFailure'fieldLocation x__)
                (Control.DeepSeq.deepseq (_InputFailure'kind x__) ()))
newtype InputFailureKind'UnrecognizedValue
  = InputFailureKind'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq,
                  Prelude.Ord,
                  Prelude.Show,
                  GHC.Generics.Generic)
instance Text.PrettyPrint.GenericPretty.Out InputFailureKind'UnrecognizedValue
data InputFailureKind
  = REQUIRED |
    NOT_FOUND |
    PARSING_FAILED |
    VERIFICATION_FAILED |
    InputFailureKind'Unrecognized !InputFailureKind'UnrecognizedValue
  deriving stock (Prelude.Show,
                  Prelude.Eq,
                  Prelude.Ord,
                  GHC.Generics.Generic)
instance Data.ProtoLens.MessageEnum InputFailureKind where
  maybeToEnum 0 = Prelude.Just REQUIRED
  maybeToEnum 1 = Prelude.Just NOT_FOUND
  maybeToEnum 2 = Prelude.Just PARSING_FAILED
  maybeToEnum 3 = Prelude.Just VERIFICATION_FAILED
  maybeToEnum k
    = Prelude.Just
        (InputFailureKind'Unrecognized
           (InputFailureKind'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum REQUIRED = "REQUIRED"
  showEnum NOT_FOUND = "NOT_FOUND"
  showEnum PARSING_FAILED = "PARSING_FAILED"
  showEnum VERIFICATION_FAILED = "VERIFICATION_FAILED"
  showEnum
    (InputFailureKind'Unrecognized (InputFailureKind'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "REQUIRED" = Prelude.Just REQUIRED
    | (Prelude.==) k "NOT_FOUND" = Prelude.Just NOT_FOUND
    | (Prelude.==) k "PARSING_FAILED" = Prelude.Just PARSING_FAILED
    | (Prelude.==) k "VERIFICATION_FAILED"
    = Prelude.Just VERIFICATION_FAILED
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded InputFailureKind where
  minBound = REQUIRED
  maxBound = VERIFICATION_FAILED
instance Prelude.Enum InputFailureKind where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum InputFailureKind: "
              (Prelude.show k__)))
        Prelude.id
        (Data.ProtoLens.maybeToEnum k__)
  fromEnum REQUIRED = 0
  fromEnum NOT_FOUND = 1
  fromEnum PARSING_FAILED = 2
  fromEnum VERIFICATION_FAILED = 3
  fromEnum
    (InputFailureKind'Unrecognized (InputFailureKind'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ VERIFICATION_FAILED
    = Prelude.error
        "InputFailureKind.succ: bad argument VERIFICATION_FAILED. This value would be out of bounds."
  succ REQUIRED = NOT_FOUND
  succ NOT_FOUND = PARSING_FAILED
  succ PARSING_FAILED = VERIFICATION_FAILED
  succ (InputFailureKind'Unrecognized _)
    = Prelude.error
        "InputFailureKind.succ: bad argument: unrecognized value"
  pred REQUIRED
    = Prelude.error
        "InputFailureKind.pred: bad argument REQUIRED. This value would be out of bounds."
  pred NOT_FOUND = REQUIRED
  pred PARSING_FAILED = NOT_FOUND
  pred VERIFICATION_FAILED = PARSING_FAILED
  pred (InputFailureKind'Unrecognized _)
    = Prelude.error
        "InputFailureKind.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault InputFailureKind where
  fieldDefault = REQUIRED
instance Control.DeepSeq.NFData InputFailureKind where
  rnf x__ = Prelude.seq x__ ()
instance Text.PrettyPrint.GenericPretty.Out InputFailureKind
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' LnPubKey Data.ByteString.ByteString@ -}
data LnPubKey
  = LnPubKey'_constructor {_LnPubKey'val :: !Data.ByteString.ByteString,
                           _LnPubKey'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnPubKey where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnPubKey
instance Data.ProtoLens.Field.HasField LnPubKey "val" Data.ByteString.ByteString where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPubKey'val (\ x__ y__ -> x__ {_LnPubKey'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnPubKey where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.LnPubKey"
  packedMessageDescriptor _
    = "\n\
      \\bLnPubKey\DC2\DLE\n\
      \\ETXval\CAN\SOH \SOH(\fR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BytesField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.ByteString.ByteString)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"val")) ::
              Data.ProtoLens.FieldDescriptor LnPubKey
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnPubKey'_unknownFields
        (\ x__ y__ -> x__ {_LnPubKey'_unknownFields = y__})
  defMessage
    = LnPubKey'_constructor
        {_LnPubKey'val = Data.ProtoLens.fieldDefault,
         _LnPubKey'_unknownFields = []}
  parseMessage
    = let
        loop :: LnPubKey -> Data.ProtoLens.Encoding.Bytes.Parser LnPubKey
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.getBytes
                                             (Prelude.fromIntegral len))
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "LnPubKey"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"val") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                      ((\ bs
                          -> (Data.Monoid.<>)
                               (Data.ProtoLens.Encoding.Bytes.putVarInt
                                  (Prelude.fromIntegral (Data.ByteString.length bs)))
                               (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LnPubKey where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnPubKey'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LnPubKey'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' LocalBalance Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' LocalBalance (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data LocalBalance
  = LocalBalance'_constructor {_LocalBalance'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                               _LocalBalance'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LocalBalance where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LocalBalance
instance Data.ProtoLens.Field.HasField LocalBalance "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LocalBalance'val (\ x__ y__ -> x__ {_LocalBalance'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LocalBalance "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LocalBalance'val (\ x__ y__ -> x__ {_LocalBalance'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LocalBalance where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.LocalBalance"
  packedMessageDescriptor _
    = "\n\
      \\fLocalBalance\DC2,\n\
      \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor LocalBalance
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LocalBalance'_unknownFields
        (\ x__ y__ -> x__ {_LocalBalance'_unknownFields = y__})
  defMessage
    = LocalBalance'_constructor
        {_LocalBalance'val = Prelude.Nothing,
         _LocalBalance'_unknownFields = []}
  parseMessage
    = let
        loop ::
          LocalBalance -> Data.ProtoLens.Encoding.Bytes.Parser LocalBalance
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "LocalBalance"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LocalBalance where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LocalBalance'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LocalBalance'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' LspLnSocketAddress Proto.BtcLsp.Data.LowLevel.SocketAddress@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' LspLnSocketAddress (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.SocketAddress)@ -}
data LspLnSocketAddress
  = LspLnSocketAddress'_constructor {_LspLnSocketAddress'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.SocketAddress),
                                     _LspLnSocketAddress'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LspLnSocketAddress where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LspLnSocketAddress
instance Data.ProtoLens.Field.HasField LspLnSocketAddress "val" Proto.BtcLsp.Data.LowLevel.SocketAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LspLnSocketAddress'val
           (\ x__ y__ -> x__ {_LspLnSocketAddress'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LspLnSocketAddress "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.SocketAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LspLnSocketAddress'val
           (\ x__ y__ -> x__ {_LspLnSocketAddress'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LspLnSocketAddress where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.LspLnSocketAddress"
  packedMessageDescriptor _
    = "\n\
      \\DC2LspLnSocketAddress\DC25\n\
      \\ETXval\CAN\SOH \SOH(\v2#.BtcLsp.Data.LowLevel.SocketAddressR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.SocketAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor LspLnSocketAddress
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LspLnSocketAddress'_unknownFields
        (\ x__ y__ -> x__ {_LspLnSocketAddress'_unknownFields = y__})
  defMessage
    = LspLnSocketAddress'_constructor
        {_LspLnSocketAddress'val = Prelude.Nothing,
         _LspLnSocketAddress'_unknownFields = []}
  parseMessage
    = let
        loop ::
          LspLnSocketAddress
          -> Data.ProtoLens.Encoding.Bytes.Parser LspLnSocketAddress
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "LspLnSocketAddress"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LspLnSocketAddress where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LspLnSocketAddress'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LspLnSocketAddress'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' Nonce Data.Word.Word64@ -}
data Nonce
  = Nonce'_constructor {_Nonce'val :: !Data.Word.Word64,
                        _Nonce'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Nonce where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Nonce
instance Data.ProtoLens.Field.HasField Nonce "val" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Nonce'val (\ x__ y__ -> x__ {_Nonce'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message Nonce where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.Nonce"
  packedMessageDescriptor _
    = "\n\
      \\ENQNonce\DC2\DLE\n\
      \\ETXval\CAN\SOH \SOH(\EOTR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"val")) ::
              Data.ProtoLens.FieldDescriptor Nonce
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Nonce'_unknownFields
        (\ x__ y__ -> x__ {_Nonce'_unknownFields = y__})
  defMessage
    = Nonce'_constructor
        {_Nonce'val = Data.ProtoLens.fieldDefault,
         _Nonce'_unknownFields = []}
  parseMessage
    = let
        loop :: Nonce -> Data.ProtoLens.Encoding.Bytes.Parser Nonce
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        8 -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Nonce"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let _v = Lens.Family2.view (Data.ProtoLens.Field.field @"val") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData Nonce where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Nonce'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Nonce'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' RefundAmt Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' RefundAmt (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data RefundAmt
  = RefundAmt'_constructor {_RefundAmt'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                            _RefundAmt'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show RefundAmt where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out RefundAmt
instance Data.ProtoLens.Field.HasField RefundAmt "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundAmt'val (\ x__ y__ -> x__ {_RefundAmt'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RefundAmt "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundAmt'val (\ x__ y__ -> x__ {_RefundAmt'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message RefundAmt where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.RefundAmt"
  packedMessageDescriptor _
    = "\n\
      \\tRefundAmt\DC2,\n\
      \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor RefundAmt
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RefundAmt'_unknownFields
        (\ x__ y__ -> x__ {_RefundAmt'_unknownFields = y__})
  defMessage
    = RefundAmt'_constructor
        {_RefundAmt'val = Prelude.Nothing, _RefundAmt'_unknownFields = []}
  parseMessage
    = let
        loop :: RefundAmt -> Data.ProtoLens.Encoding.Bytes.Parser RefundAmt
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RefundAmt"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData RefundAmt where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RefundAmt'_unknownFields x__)
             (Control.DeepSeq.deepseq (_RefundAmt'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' RefundOnChainAddress Proto.BtcLsp.Data.LowLevel.OnChainAddress@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' RefundOnChainAddress (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress)@ -}
data RefundOnChainAddress
  = RefundOnChainAddress'_constructor {_RefundOnChainAddress'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress),
                                       _RefundOnChainAddress'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show RefundOnChainAddress where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out RefundOnChainAddress
instance Data.ProtoLens.Field.HasField RefundOnChainAddress "val" Proto.BtcLsp.Data.LowLevel.OnChainAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundOnChainAddress'val
           (\ x__ y__ -> x__ {_RefundOnChainAddress'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RefundOnChainAddress "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.OnChainAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundOnChainAddress'val
           (\ x__ y__ -> x__ {_RefundOnChainAddress'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message RefundOnChainAddress where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.RefundOnChainAddress"
  packedMessageDescriptor _
    = "\n\
      \\DC4RefundOnChainAddress\DC26\n\
      \\ETXval\CAN\SOH \SOH(\v2$.BtcLsp.Data.LowLevel.OnChainAddressR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.OnChainAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor RefundOnChainAddress
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RefundOnChainAddress'_unknownFields
        (\ x__ y__ -> x__ {_RefundOnChainAddress'_unknownFields = y__})
  defMessage
    = RefundOnChainAddress'_constructor
        {_RefundOnChainAddress'val = Prelude.Nothing,
         _RefundOnChainAddress'_unknownFields = []}
  parseMessage
    = let
        loop ::
          RefundOnChainAddress
          -> Data.ProtoLens.Encoding.Bytes.Parser RefundOnChainAddress
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RefundOnChainAddress"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData RefundOnChainAddress where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RefundOnChainAddress'_unknownFields x__)
             (Control.DeepSeq.deepseq (_RefundOnChainAddress'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' RemoteBalance Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' RemoteBalance (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data RemoteBalance
  = RemoteBalance'_constructor {_RemoteBalance'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                                _RemoteBalance'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show RemoteBalance where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out RemoteBalance
instance Data.ProtoLens.Field.HasField RemoteBalance "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RemoteBalance'val (\ x__ y__ -> x__ {_RemoteBalance'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RemoteBalance "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RemoteBalance'val (\ x__ y__ -> x__ {_RemoteBalance'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message RemoteBalance where
  messageName _
    = Data.Text.pack "BtcLsp.Data.HighLevel.RemoteBalance"
  packedMessageDescriptor _
    = "\n\
      \\rRemoteBalance\DC2,\n\
      \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.LowLevel.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'val")) ::
              Data.ProtoLens.FieldDescriptor RemoteBalance
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RemoteBalance'_unknownFields
        (\ x__ y__ -> x__ {_RemoteBalance'_unknownFields = y__})
  defMessage
    = RemoteBalance'_constructor
        {_RemoteBalance'val = Prelude.Nothing,
         _RemoteBalance'_unknownFields = []}
  parseMessage
    = let
        loop ::
          RemoteBalance -> Data.ProtoLens.Encoding.Bytes.Parser RemoteBalance
        loop x
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do (let missing = []
                       in
                         if Prelude.null missing then
                             Prelude.return ()
                         else
                             Prelude.fail
                               ((Prelude.++)
                                  "Missing required fields: "
                                  (Prelude.show (missing :: [Prelude.String]))))
                      Prelude.return
                        (Lens.Family2.over
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t) x)
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "val"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"val") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "RemoteBalance"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'val") _x
              of
                Prelude.Nothing -> Data.Monoid.mempty
                (Prelude.Just _v)
                  -> (Data.Monoid.<>)
                       (Data.ProtoLens.Encoding.Bytes.putVarInt 10)
                       ((Prelude..)
                          (\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                          Data.ProtoLens.encodeMessage
                          _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData RemoteBalance where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RemoteBalance'_unknownFields x__)
             (Control.DeepSeq.deepseq (_RemoteBalance'val x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\GSbtc_lsp/data/high_level.proto\DC2\NAKBtcLsp.Data.HighLevel\SUB\FSbtc_lsp/data/low_level.proto\"K\n\
    \\DC2LspLnSocketAddress\DC25\n\
    \\ETXval\CAN\SOH \SOH(\v2#.BtcLsp.Data.LowLevel.SocketAddressR\ETXval\"<\n\
    \\aFeeRate\DC21\n\
    \\ETXval\CAN\SOH \SOH(\v2\US.BtcLsp.Data.LowLevel.UrationalR\ETXval\"6\n\
    \\ACKFeeAmt\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"7\n\
    \\aFundAmt\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"9\n\
    \\tRefundAmt\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"<\n\
    \\fLocalBalance\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"=\n\
    \\rRemoteBalance\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"B\n\
    \\rFundLnInvoice\DC21\n\
    \\ETXval\CAN\SOH \SOH(\v2\US.BtcLsp.Data.LowLevel.LnInvoiceR\ETXval\"J\n\
    \\DC1FundLnHodlInvoice\DC25\n\
    \\ETXval\CAN\SOH \SOH(\v2#.BtcLsp.Data.LowLevel.LnHodlInvoiceR\ETXval\"L\n\
    \\DC2FundOnChainAddress\DC26\n\
    \\ETXval\CAN\SOH \SOH(\v2$.BtcLsp.Data.LowLevel.OnChainAddressR\ETXval\"N\n\
    \\DC4RefundOnChainAddress\DC26\n\
    \\ETXval\CAN\SOH \SOH(\v2$.BtcLsp.Data.LowLevel.OnChainAddressR\ETXval\"x\n\
    \\ETXCtx\DC22\n\
    \\ENQnonce\CAN\SOH \SOH(\v2\FS.BtcLsp.Data.HighLevel.NonceR\ENQnonce\DC2=\n\
    \\n\
    \ln_pub_key\CAN\STX \SOH(\v2\US.BtcLsp.Data.HighLevel.LnPubKeyR\blnPubKey\"\EM\n\
    \\ENQNonce\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\EOTR\ETXval\"\FS\n\
    \\bLnPubKey\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\fR\ETXval\"\149\SOH\n\
    \\fInputFailure\DC2H\n\
    \\SOfield_location\CAN\SOH \ETX(\v2!.BtcLsp.Data.HighLevel.FieldIndexR\rfieldLocation\DC2;\n\
    \\EOTkind\CAN\STX \SOH(\SO2'.BtcLsp.Data.HighLevel.InputFailureKindR\EOTkind\"\RS\n\
    \\n\
    \FieldIndex\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\rR\ETXval*\\\n\
    \\DLEInputFailureKind\DC2\f\n\
    \\bREQUIRED\DLE\NUL\DC2\r\n\
    \\tNOT_FOUND\DLE\SOH\DC2\DC2\n\
    \\SOPARSING_FAILED\DLE\STX\DC2\ETB\n\
    \\DC3VERIFICATION_FAILED\DLE\ETXJ\214\DC4\n\
    \\ACK\DC2\EOT\NUL\NULh\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \P\n\
    \\SOH\STX\DC2\ETX\a\NUL\RS2F\n\
    \ HighLevel types are the only types\n\
    \ used directly in Grpc Methods.\n\
    \\n\
    \\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\t\NUL&\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\v\NUL\r\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\v\b\SUB\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\f\STX.\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\f\STX%\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\f&)\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\f,-\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\SI\NUL\DC1\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\SI\b\SI\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\DLE\STX*\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\DLE\STX!\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\DLE\"%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\DLE()\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\DC3\NUL\NAK\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\DC3\b\SO\n\
    \\v\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETX\DC4\STX%\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETX\DC4\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX\DC4\GS \n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX\DC4#$\n\
    \\n\
    \\n\
    \\STX\EOT\ETX\DC2\EOT\ETB\NUL\EM\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETX\ETB\b\SI\n\
    \\v\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETX\CAN\STX%\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\ETX\CAN\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX\CAN\GS \n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX\CAN#$\n\
    \\n\
    \\n\
    \\STX\EOT\EOT\DC2\EOT\ESC\NUL\GS\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\EOT\SOH\DC2\ETX\ESC\b\DC1\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\ETX\FS\STX%\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\ETX\FS\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\ETX\FS\GS \n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\ETX\FS#$\n\
    \\n\
    \\n\
    \\STX\EOT\ENQ\DC2\EOT\US\NUL!\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ENQ\SOH\DC2\ETX\US\b\DC4\n\
    \\v\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\ETX \STX%\n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\ACK\DC2\ETX \STX\FS\n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\ETX \GS \n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\ETX #$\n\
    \\n\
    \\n\
    \\STX\EOT\ACK\DC2\EOT#\NUL%\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ACK\SOH\DC2\ETX#\b\NAK\n\
    \\v\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\ETX$\STX%\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ACK\DC2\ETX$\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\ETX$\GS \n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\ETX$#$\n\
    \\n\
    \\n\
    \\STX\EOT\a\DC2\EOT'\NUL)\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\a\SOH\DC2\ETX'\b\NAK\n\
    \\v\n\
    \\EOT\EOT\a\STX\NUL\DC2\ETX(\STX*\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ACK\DC2\ETX(\STX!\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\ETX(\"%\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\ETX(()\n\
    \\n\
    \\n\
    \\STX\EOT\b\DC2\EOT+\NUL-\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\b\SOH\DC2\ETX+\b\EM\n\
    \\v\n\
    \\EOT\EOT\b\STX\NUL\DC2\ETX,\STX.\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ACK\DC2\ETX,\STX%\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\ETX,&)\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\ETX,,-\n\
    \\n\
    \\n\
    \\STX\EOT\t\DC2\EOT/\NUL1\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\t\SOH\DC2\ETX/\b\SUB\n\
    \\v\n\
    \\EOT\EOT\t\STX\NUL\DC2\ETX0\STX/\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\ACK\DC2\ETX0\STX&\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\ETX0'*\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\ETX0-.\n\
    \\n\
    \\n\
    \\STX\EOT\n\
    \\DC2\EOT3\NUL5\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\n\
    \\SOH\DC2\ETX3\b\FS\n\
    \\v\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\ETX4\STX/\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ACK\DC2\ETX4\STX&\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\ETX4'*\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\ETX4-.\n\
    \\n\
    \\n\
    \\STX\EOT\v\DC2\EOT7\NUL:\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\v\SOH\DC2\ETX7\b\v\n\
    \\v\n\
    \\EOT\EOT\v\STX\NUL\DC2\ETX8\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ACK\DC2\ETX8\STX\a\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\ETX8\b\r\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\ETX8\DLE\DC1\n\
    \\v\n\
    \\EOT\EOT\v\STX\SOH\DC2\ETX9\STX\SUB\n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\ACK\DC2\ETX9\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\SOH\DC2\ETX9\v\NAK\n\
    \\f\n\
    \\ENQ\EOT\v\STX\SOH\ETX\DC2\ETX9\CAN\EM\n\
    \\233\STX\n\
    \\STX\EOT\f\DC2\EOTF\NULH\SOH2\220\STX\n\
    \ All requests do require a nonce. The nonce is used\n\
    \ for security reasons and is used to guard against\n\
    \ replay attacks. The server will reject any request\n\
    \ that comes with an incorrect nonce. The only requirement\n\
    \ for the nonce is that it needs to be strictly increasing.\n\
    \ Nonce generation is often achieved by using the\n\
    \ current UNIX timestamp.\n\
    \\n\
    \\n\
    \\n\
    \\n\
    \\ETX\EOT\f\SOH\DC2\ETXF\b\r\n\
    \\v\n\
    \\EOT\EOT\f\STX\NUL\DC2\ETXG\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\ETXG\STX\b\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\ETXG\t\f\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\ETXG\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\r\DC2\EOTJ\NULL\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\r\SOH\DC2\ETXJ\b\DLE\n\
    \\v\n\
    \\EOT\EOT\r\STX\NUL\DC2\ETXK\STX\DLE\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\ENQ\DC2\ETXK\STX\a\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\SOH\DC2\ETXK\b\v\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\ETX\DC2\ETXK\SO\SI\n\
    \\n\
    \\n\
    \\STX\EOT\SO\DC2\EOTN\NULQ\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SO\SOH\DC2\ETXN\b\DC4\n\
    \\v\n\
    \\EOT\EOT\SO\STX\NUL\DC2\ETXO\STX)\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\EOT\DC2\ETXO\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\ACK\DC2\ETXO\v\NAK\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\SOH\DC2\ETXO\SYN$\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\ETX\DC2\ETXO'(\n\
    \\v\n\
    \\EOT\EOT\SO\STX\SOH\DC2\ETXP\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\SOH\ACK\DC2\ETXP\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\SOH\SOH\DC2\ETXP\DC3\ETB\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\SOH\ETX\DC2\ETXP\SUB\ESC\n\
    \\n\
    \\n\
    \\STX\EOT\SI\DC2\EOTS\NULU\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SI\SOH\DC2\ETXS\b\DC2\n\
    \\v\n\
    \\EOT\EOT\SI\STX\NUL\DC2\ETXT\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\ENQ\DC2\ETXT\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\SOH\DC2\ETXT\t\f\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\ETX\DC2\ETXT\SI\DLE\n\
    \\n\
    \\n\
    \\STX\ENQ\NUL\DC2\EOTW\NULh\SOH\n\
    \\n\
    \\n\
    \\ETX\ENQ\NUL\SOH\DC2\ETXW\ENQ\NAK\n\
    \l\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\ETXZ\STX\SI\SUB_ All proto3 messages are optional, but sometimes\n\
    \ message presence is required by source code.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETXZ\STX\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETXZ\r\SO\n\
    \\182\SOH\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\ETX^\STX\DLE\SUB\168\SOH Sometimes protobuf term is not data itself, but reference\n\
    \ to some other data, located somewhere else, for example\n\
    \ in database, and this resource might be not found.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETX^\STX\v\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETX^\SO\SI\n\
    \\201\SOH\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\ETXc\STX\NAK\SUB\187\SOH Sometimes data is required to be in some\n\
    \ specific format (for example DER binary encoding)\n\
    \ which is not the part of proto3 type system.\n\
    \ This error shows the failure of custom parser.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETXc\STX\DLE\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETXc\DC3\DC4\n\
    \\157\SOH\n\
    \\EOT\ENQ\NUL\STX\ETX\DC2\ETXg\STX\SUB\SUB\143\SOH Even if custom parser succeeded, sometimes data\n\
    \ needs to be verified somehow, for example\n\
    \ signature needs to be cryptographically verified.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETXg\STX\NAK\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETXg\CAN\EMb\ACKproto3"