{- This file was auto-generated from btc_lsp/data/type.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Data.Type (
        Ctx(), FeeRate(), InputFailure(), InputFailureKind(..),
        InputFailureKind(), InputFailureKind'UnrecognizedValue, Rational(),
        Urational()
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
import qualified Proto.BtcLsp.Data.Newtype
{- | Fields :
     
         * 'Proto.BtcLsp.Data.Type_Fields.nonce' @:: Lens' Ctx Proto.BtcLsp.Data.Newtype.Nonce@
         * 'Proto.BtcLsp.Data.Type_Fields.maybe'nonce' @:: Lens' Ctx (Prelude.Maybe Proto.BtcLsp.Data.Newtype.Nonce)@
         * 'Proto.BtcLsp.Data.Type_Fields.lnPubKey' @:: Lens' Ctx Proto.BtcLsp.Data.Newtype.LnPubKey@
         * 'Proto.BtcLsp.Data.Type_Fields.maybe'lnPubKey' @:: Lens' Ctx (Prelude.Maybe Proto.BtcLsp.Data.Newtype.LnPubKey)@ -}
data Ctx
  = Ctx'_constructor {_Ctx'nonce :: !(Prelude.Maybe Proto.BtcLsp.Data.Newtype.Nonce),
                      _Ctx'lnPubKey :: !(Prelude.Maybe Proto.BtcLsp.Data.Newtype.LnPubKey),
                      _Ctx'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Ctx where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Ctx
instance Data.ProtoLens.Field.HasField Ctx "nonce" Proto.BtcLsp.Data.Newtype.Nonce where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'nonce" (Prelude.Maybe Proto.BtcLsp.Data.Newtype.Nonce) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Ctx "lnPubKey" Proto.BtcLsp.Data.Newtype.LnPubKey where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'lnPubKey (\ x__ y__ -> x__ {_Ctx'lnPubKey = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'lnPubKey" (Prelude.Maybe Proto.BtcLsp.Data.Newtype.LnPubKey) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'lnPubKey (\ x__ y__ -> x__ {_Ctx'lnPubKey = y__}))
        Prelude.id
instance Data.ProtoLens.Message Ctx where
  messageName _ = Data.Text.pack "BtcLsp.Data.Type.Ctx"
  packedMessageDescriptor _
    = "\n\
      \\ETXCtx\DC20\n\
      \\ENQnonce\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.Newtype.NonceR\ENQnonce\DC2;\n\
      \\n\
      \ln_pub_key\CAN\STX \SOH(\v2\GS.BtcLsp.Data.Newtype.LnPubKeyR\blnPubKey"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nonce__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "nonce"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.Newtype.Nonce)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'nonce")) ::
              Data.ProtoLens.FieldDescriptor Ctx
        lnPubKey__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ln_pub_key"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.Newtype.LnPubKey)
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
     
         * 'Proto.BtcLsp.Data.Type_Fields.val' @:: Lens' FeeRate Urational@
         * 'Proto.BtcLsp.Data.Type_Fields.maybe'val' @:: Lens' FeeRate (Prelude.Maybe Urational)@ -}
data FeeRate
  = FeeRate'_constructor {_FeeRate'val :: !(Prelude.Maybe Urational),
                          _FeeRate'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FeeRate where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FeeRate
instance Data.ProtoLens.Field.HasField FeeRate "val" Urational where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeRate'val (\ x__ y__ -> x__ {_FeeRate'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FeeRate "maybe'val" (Prelude.Maybe Urational) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeRate'val (\ x__ y__ -> x__ {_FeeRate'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FeeRate where
  messageName _ = Data.Text.pack "BtcLsp.Data.Type.FeeRate"
  packedMessageDescriptor _
    = "\n\
      \\aFeeRate\DC2-\n\
      \\ETXval\CAN\SOH \SOH(\v2\ESC.BtcLsp.Data.Type.UrationalR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Urational)
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
     
         * 'Proto.BtcLsp.Data.Type_Fields.fieldLocation' @:: Lens' InputFailure [Proto.BtcLsp.Data.Newtype.FieldIndex]@
         * 'Proto.BtcLsp.Data.Type_Fields.vec'fieldLocation' @:: Lens' InputFailure (Data.Vector.Vector Proto.BtcLsp.Data.Newtype.FieldIndex)@
         * 'Proto.BtcLsp.Data.Type_Fields.kind' @:: Lens' InputFailure InputFailureKind@ -}
data InputFailure
  = InputFailure'_constructor {_InputFailure'fieldLocation :: !(Data.Vector.Vector Proto.BtcLsp.Data.Newtype.FieldIndex),
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
instance Data.ProtoLens.Field.HasField InputFailure "fieldLocation" [Proto.BtcLsp.Data.Newtype.FieldIndex] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InputFailure "vec'fieldLocation" (Data.Vector.Vector Proto.BtcLsp.Data.Newtype.FieldIndex) where
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
  messageName _ = Data.Text.pack "BtcLsp.Data.Type.InputFailure"
  packedMessageDescriptor _
    = "\n\
      \\fInputFailure\DC2F\n\
      \\SOfield_location\CAN\SOH \ETX(\v2\US.BtcLsp.Data.Newtype.FieldIndexR\rfieldLocation\DC26\n\
      \\EOTkind\CAN\STX \SOH(\SO2\".BtcLsp.Data.Type.InputFailureKindR\EOTkind"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fieldLocation__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "field_location"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.Newtype.FieldIndex)
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
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.BtcLsp.Data.Newtype.FieldIndex
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
     
         * 'Proto.BtcLsp.Data.Type_Fields.negative' @:: Lens' Rational Prelude.Bool@
         * 'Proto.BtcLsp.Data.Type_Fields.numerator' @:: Lens' Rational Data.Word.Word64@
         * 'Proto.BtcLsp.Data.Type_Fields.denominator' @:: Lens' Rational Data.Word.Word64@ -}
data Rational
  = Rational'_constructor {_Rational'negative :: !Prelude.Bool,
                           _Rational'numerator :: !Data.Word.Word64,
                           _Rational'denominator :: !Data.Word.Word64,
                           _Rational'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Rational where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Rational
instance Data.ProtoLens.Field.HasField Rational "negative" Prelude.Bool where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Rational'negative (\ x__ y__ -> x__ {_Rational'negative = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Rational "numerator" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Rational'numerator (\ x__ y__ -> x__ {_Rational'numerator = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Rational "denominator" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Rational'denominator
           (\ x__ y__ -> x__ {_Rational'denominator = y__}))
        Prelude.id
instance Data.ProtoLens.Message Rational where
  messageName _ = Data.Text.pack "BtcLsp.Data.Type.Rational"
  packedMessageDescriptor _
    = "\n\
      \\bRational\DC2\SUB\n\
      \\bnegative\CAN\SOH \SOH(\bR\bnegative\DC2\FS\n\
      \\tnumerator\CAN\STX \SOH(\EOTR\tnumerator\DC2 \n\
      \\vdenominator\CAN\ETX \SOH(\EOTR\vdenominator"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        negative__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "negative"
              (Data.ProtoLens.ScalarField Data.ProtoLens.BoolField ::
                 Data.ProtoLens.FieldTypeDescriptor Prelude.Bool)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"negative")) ::
              Data.ProtoLens.FieldDescriptor Rational
        numerator__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "numerator"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"numerator")) ::
              Data.ProtoLens.FieldDescriptor Rational
        denominator__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "denominator"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"denominator")) ::
              Data.ProtoLens.FieldDescriptor Rational
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, negative__field_descriptor),
           (Data.ProtoLens.Tag 2, numerator__field_descriptor),
           (Data.ProtoLens.Tag 3, denominator__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Rational'_unknownFields
        (\ x__ y__ -> x__ {_Rational'_unknownFields = y__})
  defMessage
    = Rational'_constructor
        {_Rational'negative = Data.ProtoLens.fieldDefault,
         _Rational'numerator = Data.ProtoLens.fieldDefault,
         _Rational'denominator = Data.ProtoLens.fieldDefault,
         _Rational'_unknownFields = []}
  parseMessage
    = let
        loop :: Rational -> Data.ProtoLens.Encoding.Bytes.Parser Rational
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
                                          ((Prelude./=) 0) Data.ProtoLens.Encoding.Bytes.getVarInt)
                                       "negative"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"negative") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "numerator"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"numerator") y x)
                        24
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "denominator"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"denominator") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Rational"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"negative") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      ((Prelude..)
                         Data.ProtoLens.Encoding.Bytes.putVarInt
                         (\ b -> if b then 1 else 0)
                         _v))
             ((Data.Monoid.<>)
                (let
                   _v = Lens.Family2.view (Data.ProtoLens.Field.field @"numerator") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                ((Data.Monoid.<>)
                   (let
                      _v
                        = Lens.Family2.view (Data.ProtoLens.Field.field @"denominator") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 24)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Rational where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Rational'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Rational'negative x__)
                (Control.DeepSeq.deepseq
                   (_Rational'numerator x__)
                   (Control.DeepSeq.deepseq (_Rational'denominator x__) ())))
{- | Fields :
     
         * 'Proto.BtcLsp.Data.Type_Fields.numerator' @:: Lens' Urational Data.Word.Word64@
         * 'Proto.BtcLsp.Data.Type_Fields.denominator' @:: Lens' Urational Data.Word.Word64@ -}
data Urational
  = Urational'_constructor {_Urational'numerator :: !Data.Word.Word64,
                            _Urational'denominator :: !Data.Word.Word64,
                            _Urational'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Urational where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Urational
instance Data.ProtoLens.Field.HasField Urational "numerator" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Urational'numerator
           (\ x__ y__ -> x__ {_Urational'numerator = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Urational "denominator" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Urational'denominator
           (\ x__ y__ -> x__ {_Urational'denominator = y__}))
        Prelude.id
instance Data.ProtoLens.Message Urational where
  messageName _ = Data.Text.pack "BtcLsp.Data.Type.Urational"
  packedMessageDescriptor _
    = "\n\
      \\tUrational\DC2\FS\n\
      \\tnumerator\CAN\SOH \SOH(\EOTR\tnumerator\DC2 \n\
      \\vdenominator\CAN\STX \SOH(\EOTR\vdenominator"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        numerator__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "numerator"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"numerator")) ::
              Data.ProtoLens.FieldDescriptor Urational
        denominator__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "denominator"
              (Data.ProtoLens.ScalarField Data.ProtoLens.UInt64Field ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Word.Word64)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional
                 (Data.ProtoLens.Field.field @"denominator")) ::
              Data.ProtoLens.FieldDescriptor Urational
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, numerator__field_descriptor),
           (Data.ProtoLens.Tag 2, denominator__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Urational'_unknownFields
        (\ x__ y__ -> x__ {_Urational'_unknownFields = y__})
  defMessage
    = Urational'_constructor
        {_Urational'numerator = Data.ProtoLens.fieldDefault,
         _Urational'denominator = Data.ProtoLens.fieldDefault,
         _Urational'_unknownFields = []}
  parseMessage
    = let
        loop :: Urational -> Data.ProtoLens.Encoding.Bytes.Parser Urational
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
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "numerator"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"numerator") y x)
                        16
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       Data.ProtoLens.Encoding.Bytes.getVarInt "denominator"
                                loop
                                  (Lens.Family2.set (Data.ProtoLens.Field.field @"denominator") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Urational"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (let
                _v = Lens.Family2.view (Data.ProtoLens.Field.field @"numerator") _x
              in
                if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                    Data.Monoid.mempty
                else
                    (Data.Monoid.<>)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt 8)
                      (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
             ((Data.Monoid.<>)
                (let
                   _v
                     = Lens.Family2.view (Data.ProtoLens.Field.field @"denominator") _x
                 in
                   if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 16)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Urational where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Urational'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Urational'numerator x__)
                (Control.DeepSeq.deepseq (_Urational'denominator x__) ()))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\ETBbtc_lsp/data/type.proto\DC2\DLEBtcLsp.Data.Type\SUB\SUBbtc_lsp/data/newtype.proto\"t\n\
    \\ETXCtx\DC20\n\
    \\ENQnonce\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.Newtype.NonceR\ENQnonce\DC2;\n\
    \\n\
    \ln_pub_key\CAN\STX \SOH(\v2\GS.BtcLsp.Data.Newtype.LnPubKeyR\blnPubKey\"f\n\
    \\bRational\DC2\SUB\n\
    \\bnegative\CAN\SOH \SOH(\bR\bnegative\DC2\FS\n\
    \\tnumerator\CAN\STX \SOH(\EOTR\tnumerator\DC2 \n\
    \\vdenominator\CAN\ETX \SOH(\EOTR\vdenominator\"K\n\
    \\tUrational\DC2\FS\n\
    \\tnumerator\CAN\SOH \SOH(\EOTR\tnumerator\DC2 \n\
    \\vdenominator\CAN\STX \SOH(\EOTR\vdenominator\"8\n\
    \\aFeeRate\DC2-\n\
    \\ETXval\CAN\SOH \SOH(\v2\ESC.BtcLsp.Data.Type.UrationalR\ETXval\"\142\SOH\n\
    \\fInputFailure\DC2F\n\
    \\SOfield_location\CAN\SOH \ETX(\v2\US.BtcLsp.Data.Newtype.FieldIndexR\rfieldLocation\DC26\n\
    \\EOTkind\CAN\STX \SOH(\SO2\".BtcLsp.Data.Type.InputFailureKindR\EOTkind*\\\n\
    \\DLEInputFailureKind\DC2\f\n\
    \\bREQUIRED\DLE\NUL\DC2\r\n\
    \\tNOT_FOUND\DLE\SOH\DC2\DC2\n\
    \\SOPARSING_FAILED\DLE\STX\DC2\ETB\n\
    \\DC3VERIFICATION_FAILED\DLE\ETXJ\238\v\n\
    \\ACK\DC2\EOT\NUL\NUL0\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\STX\NUL\EM\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\EOT\NUL$\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ACK\NUL\t\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ACK\b\v\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\a\STX'\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\a\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\a\GS\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\a%&\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\b\STX/\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\b\STX\US\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\b *\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\b-.\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\v\NUL\SI\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\v\b\DLE\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\f\STX\DC4\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ENQ\DC2\ETX\f\STX\ACK\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\f\a\SI\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\f\DC2\DC3\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\r\STX\ETB\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ENQ\DC2\ETX\r\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\r\t\DC2\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\r\NAK\SYN\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX\SO\STX\EM\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ENQ\DC2\ETX\SO\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX\SO\t\DC4\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX\SO\ETB\CAN\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\DC1\NUL\DC4\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\DC1\b\DC1\n\
    \\v\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETX\DC2\STX\ETB\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ENQ\DC2\ETX\DC2\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX\DC2\t\DC2\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX\DC2\NAK\SYN\n\
    \\v\n\
    \\EOT\EOT\STX\STX\SOH\DC2\ETX\DC3\STX\EM\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ENQ\DC2\ETX\DC3\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\ETX\DC3\t\DC4\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\ETX\DC3\ETB\CAN\n\
    \\n\
    \\n\
    \\STX\EOT\ETX\DC2\EOT\SYN\NUL\CAN\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETX\SYN\b\SI\n\
    \\v\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETX\ETB\STX\DC4\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ACK\DC2\ETX\ETB\STX\v\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX\ETB\f\SI\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX\ETB\DC2\DC3\n\
    \\n\
    \\n\
    \\STX\EOT\EOT\DC2\EOT\SUB\NUL\GS\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\EOT\SOH\DC2\ETX\SUB\b\DC4\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\ETX\ESC\STX>\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\EOT\DC2\ETX\ESC\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\ETX\ESC\v*\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\ETX\ESC+9\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\ETX\ESC<=\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\SOH\DC2\ETX\FS\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\ACK\DC2\ETX\FS\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\SOH\DC2\ETX\FS\DC3\ETB\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\SOH\ETX\DC2\ETX\FS\SUB\ESC\n\
    \\n\
    \\n\
    \\STX\ENQ\NUL\DC2\EOT\US\NUL0\SOH\n\
    \\n\
    \\n\
    \\ETX\ENQ\NUL\SOH\DC2\ETX\US\ENQ\NAK\n\
    \l\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\ETX\"\STX\SI\SUB_ All proto3 messages are optional, but sometimes\n\
    \ message presence is required by source code.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETX\"\STX\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETX\"\r\SO\n\
    \\182\SOH\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\ETX&\STX\DLE\SUB\168\SOH Sometimes protobuf term is not data itself, but reference\n\
    \ to some other data, located somewhere else, for example\n\
    \ in database, and this resource might be not found.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETX&\STX\v\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETX&\SO\SI\n\
    \\201\SOH\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\ETX+\STX\NAK\SUB\187\SOH Sometimes data is required to be in some\n\
    \ specific format (for example DER binary encoding)\n\
    \ which is not the part of proto3 type system.\n\
    \ This error shows the failure of custom parser.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETX+\STX\DLE\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETX+\DC3\DC4\n\
    \\157\SOH\n\
    \\EOT\ENQ\NUL\STX\ETX\DC2\ETX/\STX\SUB\SUB\143\SOH Even if custom parser succeeded, sometimes data\n\
    \ needs to be verified somehow, for example\n\
    \ signature needs to be cryptographically verified.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETX/\STX\NAK\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETX/\CAN\EMb\ACKproto3"