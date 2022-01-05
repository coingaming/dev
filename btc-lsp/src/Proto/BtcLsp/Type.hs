{- This file was auto-generated from btc_lsp/type.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Type (
        Ctx(), InputFailure(), InputFailureKind(..), InputFailureKind(),
        InputFailureKind'UnrecognizedValue
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
import qualified Proto.BtcLsp.Newtype
{- | Fields :
     
         * 'Proto.BtcLsp.Type_Fields.nonce' @:: Lens' Ctx Proto.BtcLsp.Newtype.Nonce@
         * 'Proto.BtcLsp.Type_Fields.maybe'nonce' @:: Lens' Ctx (Prelude.Maybe Proto.BtcLsp.Newtype.Nonce)@
         * 'Proto.BtcLsp.Type_Fields.pubKey' @:: Lens' Ctx Proto.BtcLsp.Newtype.NodePubKey@
         * 'Proto.BtcLsp.Type_Fields.maybe'pubKey' @:: Lens' Ctx (Prelude.Maybe Proto.BtcLsp.Newtype.NodePubKey)@ -}
data Ctx
  = Ctx'_constructor {_Ctx'nonce :: !(Prelude.Maybe Proto.BtcLsp.Newtype.Nonce),
                      _Ctx'pubKey :: !(Prelude.Maybe Proto.BtcLsp.Newtype.NodePubKey),
                      _Ctx'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Ctx where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Ctx
instance Data.ProtoLens.Field.HasField Ctx "nonce" Proto.BtcLsp.Newtype.Nonce where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'nonce" (Prelude.Maybe Proto.BtcLsp.Newtype.Nonce) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Ctx "pubKey" Proto.BtcLsp.Newtype.NodePubKey where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'pubKey (\ x__ y__ -> x__ {_Ctx'pubKey = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'pubKey" (Prelude.Maybe Proto.BtcLsp.Newtype.NodePubKey) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'pubKey (\ x__ y__ -> x__ {_Ctx'pubKey = y__}))
        Prelude.id
instance Data.ProtoLens.Message Ctx where
  messageName _ = Data.Text.pack "BtcLsp.Type.Ctx"
  packedMessageDescriptor _
    = "\n\
      \\ETXCtx\DC2+\n\
      \\ENQnonce\CAN\SOH \SOH(\v2\NAK.BtcLsp.Newtype.NonceR\ENQnonce\DC23\n\
      \\apub_key\CAN\STX \SOH(\v2\SUB.BtcLsp.Newtype.NodePubKeyR\ACKpubKey"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nonce__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "nonce"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Newtype.Nonce)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'nonce")) ::
              Data.ProtoLens.FieldDescriptor Ctx
        pubKey__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "pub_key"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Newtype.NodePubKey)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'pubKey")) ::
              Data.ProtoLens.FieldDescriptor Ctx
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, nonce__field_descriptor),
           (Data.ProtoLens.Tag 2, pubKey__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Ctx'_unknownFields (\ x__ y__ -> x__ {_Ctx'_unknownFields = y__})
  defMessage
    = Ctx'_constructor
        {_Ctx'nonce = Prelude.Nothing, _Ctx'pubKey = Prelude.Nothing,
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
                                       "pub_key"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"pubKey") y x)
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
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'pubKey") _x
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
                (_Ctx'nonce x__) (Control.DeepSeq.deepseq (_Ctx'pubKey x__) ()))
{- | Fields :
     
         * 'Proto.BtcLsp.Type_Fields.fieldLocation' @:: Lens' InputFailure [Proto.BtcLsp.Newtype.FieldIndex]@
         * 'Proto.BtcLsp.Type_Fields.vec'fieldLocation' @:: Lens' InputFailure (Data.Vector.Vector Proto.BtcLsp.Newtype.FieldIndex)@
         * 'Proto.BtcLsp.Type_Fields.kind' @:: Lens' InputFailure InputFailureKind@ -}
data InputFailure
  = InputFailure'_constructor {_InputFailure'fieldLocation :: !(Data.Vector.Vector Proto.BtcLsp.Newtype.FieldIndex),
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
instance Data.ProtoLens.Field.HasField InputFailure "fieldLocation" [Proto.BtcLsp.Newtype.FieldIndex] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InputFailure "vec'fieldLocation" (Data.Vector.Vector Proto.BtcLsp.Newtype.FieldIndex) where
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
  messageName _ = Data.Text.pack "BtcLsp.Type.InputFailure"
  packedMessageDescriptor _
    = "\n\
      \\fInputFailure\DC2A\n\
      \\SOfield_location\CAN\SOH \ETX(\v2\SUB.BtcLsp.Newtype.FieldIndexR\rfieldLocation\DC21\n\
      \\EOTkind\CAN\STX \SOH(\SO2\GS.BtcLsp.Type.InputFailureKindR\EOTkind"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fieldLocation__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "field_location"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Newtype.FieldIndex)
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
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.BtcLsp.Newtype.FieldIndex
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
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\DC2btc_lsp/type.proto\DC2\vBtcLsp.Type\SUB\NAKbtc_lsp/newtype.proto\"g\n\
    \\ETXCtx\DC2+\n\
    \\ENQnonce\CAN\SOH \SOH(\v2\NAK.BtcLsp.Newtype.NonceR\ENQnonce\DC23\n\
    \\apub_key\CAN\STX \SOH(\v2\SUB.BtcLsp.Newtype.NodePubKeyR\ACKpubKey\"\132\SOH\n\
    \\fInputFailure\DC2A\n\
    \\SOfield_location\CAN\SOH \ETX(\v2\SUB.BtcLsp.Newtype.FieldIndexR\rfieldLocation\DC21\n\
    \\EOTkind\CAN\STX \SOH(\SO2\GS.BtcLsp.Type.InputFailureKindR\EOTkind*\\\n\
    \\DLEInputFailureKind\DC2\f\n\
    \\bREQUIRED\DLE\NUL\DC2\r\n\
    \\tNOT_FOUND\DLE\SOH\DC2\DC2\n\
    \\SOPARSING_FAILED\DLE\STX\DC2\ETB\n\
    \\DC3VERIFICATION_FAILED\DLE\ETXJ\220\b\n\
    \\ACK\DC2\EOT\NUL\NUL!\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\STX\NUL\DC4\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\EOT\NUL\US\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ACK\NUL\t\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ACK\b\v\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\a\STX\"\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\a\STX\ETB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\a\CAN\GS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\a !\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\b\STX)\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\b\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\b\GS$\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\b'(\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\v\NUL\SO\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\v\b\DC4\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\f\STX9\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\ETX\f\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\f\v%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\f&4\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\f78\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\r\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX\r\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\r\DC3\ETB\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\r\SUB\ESC\n\
    \\n\
    \\n\
    \\STX\ENQ\NUL\DC2\EOT\DLE\NUL!\SOH\n\
    \\n\
    \\n\
    \\ETX\ENQ\NUL\SOH\DC2\ETX\DLE\ENQ\NAK\n\
    \l\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\ETX\DC3\STX\SI\SUB_ All proto3 messages are optional, but sometimes\n\
    \ message presence is required by source code.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETX\DC3\STX\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETX\DC3\r\SO\n\
    \\182\SOH\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\ETX\ETB\STX\DLE\SUB\168\SOH Sometimes protobuf term is not data itself, but reference\n\
    \ to some other data, located somewhere else, for example\n\
    \ in database, and this resource might be not found.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETX\ETB\STX\v\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETX\ETB\SO\SI\n\
    \\201\SOH\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\ETX\FS\STX\NAK\SUB\187\SOH Sometimes data is required to be in some\n\
    \ specific format (for example DER binary encoding)\n\
    \ which is not the part of proto3 type system.\n\
    \ This error shows the failure of custom parser.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETX\FS\STX\DLE\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETX\FS\DC3\DC4\n\
    \\157\SOH\n\
    \\EOT\ENQ\NUL\STX\ETX\DC2\ETX \STX\SUB\SUB\143\SOH Even if custom parser succeeded, sometimes data\n\
    \ needs to be verified somehow, for example\n\
    \ signature needs to be cryptographically verified.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETX \STX\NAK\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETX \CAN\EMb\ACKproto3"