{- This file was auto-generated from lsp/type.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Lsp.Type (
        Ctx(), Failure(), FailureKind(..), FailureKind(),
        FailureKind'UnrecognizedValue, InputFailure()
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
import qualified Proto.Lsp.Newtype
{- | Fields :
     
         * 'Proto.Lsp.Type_Fields.nonce' @:: Lens' Ctx Proto.Lsp.Newtype.Nonce@
         * 'Proto.Lsp.Type_Fields.maybe'nonce' @:: Lens' Ctx (Prelude.Maybe Proto.Lsp.Newtype.Nonce)@
         * 'Proto.Lsp.Type_Fields.pubKey' @:: Lens' Ctx Proto.Lsp.Newtype.NodePubKey@
         * 'Proto.Lsp.Type_Fields.maybe'pubKey' @:: Lens' Ctx (Prelude.Maybe Proto.Lsp.Newtype.NodePubKey)@ -}
data Ctx
  = Ctx'_constructor {_Ctx'nonce :: !(Prelude.Maybe Proto.Lsp.Newtype.Nonce),
                      _Ctx'pubKey :: !(Prelude.Maybe Proto.Lsp.Newtype.NodePubKey),
                      _Ctx'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Ctx where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Ctx
instance Data.ProtoLens.Field.HasField Ctx "nonce" Proto.Lsp.Newtype.Nonce where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'nonce" (Prelude.Maybe Proto.Lsp.Newtype.Nonce) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'nonce (\ x__ y__ -> x__ {_Ctx'nonce = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Ctx "pubKey" Proto.Lsp.Newtype.NodePubKey where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'pubKey (\ x__ y__ -> x__ {_Ctx'pubKey = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Ctx "maybe'pubKey" (Prelude.Maybe Proto.Lsp.Newtype.NodePubKey) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Ctx'pubKey (\ x__ y__ -> x__ {_Ctx'pubKey = y__}))
        Prelude.id
instance Data.ProtoLens.Message Ctx where
  messageName _ = Data.Text.pack "Lsp.Type.Ctx"
  packedMessageDescriptor _
    = "\n\
      \\ETXCtx\DC2(\n\
      \\ENQnonce\CAN\SOH \SOH(\v2\DC2.Lsp.Newtype.NonceR\ENQnonce\DC20\n\
      \\apub_key\CAN\STX \SOH(\v2\ETB.Lsp.Newtype.NodePubKeyR\ACKpubKey"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        nonce__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "nonce"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.Nonce)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'nonce")) ::
              Data.ProtoLens.FieldDescriptor Ctx
        pubKey__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "pub_key"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.NodePubKey)
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
     
         * 'Proto.Lsp.Type_Fields.input' @:: Lens' Failure [InputFailure]@
         * 'Proto.Lsp.Type_Fields.vec'input' @:: Lens' Failure (Data.Vector.Vector InputFailure)@
         * 'Proto.Lsp.Type_Fields.internal' @:: Lens' Failure [Proto.Lsp.Newtype.InternalFailure]@
         * 'Proto.Lsp.Type_Fields.vec'internal' @:: Lens' Failure (Data.Vector.Vector Proto.Lsp.Newtype.InternalFailure)@ -}
data Failure
  = Failure'_constructor {_Failure'input :: !(Data.Vector.Vector InputFailure),
                          _Failure'internal :: !(Data.Vector.Vector Proto.Lsp.Newtype.InternalFailure),
                          _Failure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Failure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Failure
instance Data.ProtoLens.Field.HasField Failure "input" [InputFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Failure'input (\ x__ y__ -> x__ {_Failure'input = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Failure "vec'input" (Data.Vector.Vector InputFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Failure'input (\ x__ y__ -> x__ {_Failure'input = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Failure "internal" [Proto.Lsp.Newtype.InternalFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Failure'internal (\ x__ y__ -> x__ {_Failure'internal = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Failure "vec'internal" (Data.Vector.Vector Proto.Lsp.Newtype.InternalFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Failure'internal (\ x__ y__ -> x__ {_Failure'internal = y__}))
        Prelude.id
instance Data.ProtoLens.Message Failure where
  messageName _ = Data.Text.pack "Lsp.Type.Failure"
  packedMessageDescriptor _
    = "\n\
      \\aFailure\DC2,\n\
      \\ENQinput\CAN\SOH \ETX(\v2\SYN.Lsp.Type.InputFailureR\ENQinput\DC28\n\
      \\binternal\CAN\STX \ETX(\v2\FS.Lsp.Newtype.InternalFailureR\binternal"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        input__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "input"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor InputFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"input")) ::
              Data.ProtoLens.FieldDescriptor Failure
        internal__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "internal"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.InternalFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"internal")) ::
              Data.ProtoLens.FieldDescriptor Failure
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, input__field_descriptor),
           (Data.ProtoLens.Tag 2, internal__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Failure'_unknownFields
        (\ x__ y__ -> x__ {_Failure'_unknownFields = y__})
  defMessage
    = Failure'_constructor
        {_Failure'input = Data.Vector.Generic.empty,
         _Failure'internal = Data.Vector.Generic.empty,
         _Failure'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Failure
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld InputFailure
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Lsp.Newtype.InternalFailure
                -> Data.ProtoLens.Encoding.Bytes.Parser Failure
        loop x mutable'input mutable'internal
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'input <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                        (Data.ProtoLens.Encoding.Growing.unsafeFreeze mutable'input)
                      frozen'internal <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                              mutable'internal)
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
                              (Data.ProtoLens.Field.field @"vec'input")
                              frozen'input
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'internal") frozen'internal x)))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "input"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'input y)
                                loop x v mutable'internal
                        18
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "internal"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'internal y)
                                loop x mutable'input v
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'input
                                  mutable'internal
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'input <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                 Data.ProtoLens.Encoding.Growing.new
              mutable'internal <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                    Data.ProtoLens.Encoding.Growing.new
              loop Data.ProtoLens.defMessage mutable'input mutable'internal)
          "Failure"
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
                (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'input") _x))
             ((Data.Monoid.<>)
                (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                   (\ _v
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
                   (Lens.Family2.view
                      (Data.ProtoLens.Field.field @"vec'internal") _x))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Failure where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Failure'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Failure'input x__)
                (Control.DeepSeq.deepseq (_Failure'internal x__) ()))
newtype FailureKind'UnrecognizedValue
  = FailureKind'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq,
                  Prelude.Ord,
                  Prelude.Show,
                  GHC.Generics.Generic)
instance Text.PrettyPrint.GenericPretty.Out FailureKind'UnrecognizedValue
data FailureKind
  = REQUIRED |
    PARSING_FAILED |
    VERIFICATION_FAILED |
    NOT_SUPPORTED |
    NOT_FOUND |
    INSUFFICIENT_FUNDS |
    NOT_UNIQUE |
    FailureKind'Unrecognized !FailureKind'UnrecognizedValue
  deriving stock (Prelude.Show,
                  Prelude.Eq,
                  Prelude.Ord,
                  GHC.Generics.Generic)
instance Data.ProtoLens.MessageEnum FailureKind where
  maybeToEnum 0 = Prelude.Just REQUIRED
  maybeToEnum 1 = Prelude.Just PARSING_FAILED
  maybeToEnum 2 = Prelude.Just VERIFICATION_FAILED
  maybeToEnum 3 = Prelude.Just NOT_SUPPORTED
  maybeToEnum 4 = Prelude.Just NOT_FOUND
  maybeToEnum 5 = Prelude.Just INSUFFICIENT_FUNDS
  maybeToEnum 6 = Prelude.Just NOT_UNIQUE
  maybeToEnum k
    = Prelude.Just
        (FailureKind'Unrecognized
           (FailureKind'UnrecognizedValue (Prelude.fromIntegral k)))
  showEnum REQUIRED = "REQUIRED"
  showEnum PARSING_FAILED = "PARSING_FAILED"
  showEnum VERIFICATION_FAILED = "VERIFICATION_FAILED"
  showEnum NOT_SUPPORTED = "NOT_SUPPORTED"
  showEnum NOT_FOUND = "NOT_FOUND"
  showEnum INSUFFICIENT_FUNDS = "INSUFFICIENT_FUNDS"
  showEnum NOT_UNIQUE = "NOT_UNIQUE"
  showEnum
    (FailureKind'Unrecognized (FailureKind'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "REQUIRED" = Prelude.Just REQUIRED
    | (Prelude.==) k "PARSING_FAILED" = Prelude.Just PARSING_FAILED
    | (Prelude.==) k "VERIFICATION_FAILED"
    = Prelude.Just VERIFICATION_FAILED
    | (Prelude.==) k "NOT_SUPPORTED" = Prelude.Just NOT_SUPPORTED
    | (Prelude.==) k "NOT_FOUND" = Prelude.Just NOT_FOUND
    | (Prelude.==) k "INSUFFICIENT_FUNDS"
    = Prelude.Just INSUFFICIENT_FUNDS
    | (Prelude.==) k "NOT_UNIQUE" = Prelude.Just NOT_UNIQUE
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded FailureKind where
  minBound = REQUIRED
  maxBound = NOT_UNIQUE
instance Prelude.Enum FailureKind where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum FailureKind: " (Prelude.show k__)))
        Prelude.id
        (Data.ProtoLens.maybeToEnum k__)
  fromEnum REQUIRED = 0
  fromEnum PARSING_FAILED = 1
  fromEnum VERIFICATION_FAILED = 2
  fromEnum NOT_SUPPORTED = 3
  fromEnum NOT_FOUND = 4
  fromEnum INSUFFICIENT_FUNDS = 5
  fromEnum NOT_UNIQUE = 6
  fromEnum
    (FailureKind'Unrecognized (FailureKind'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ NOT_UNIQUE
    = Prelude.error
        "FailureKind.succ: bad argument NOT_UNIQUE. This value would be out of bounds."
  succ REQUIRED = PARSING_FAILED
  succ PARSING_FAILED = VERIFICATION_FAILED
  succ VERIFICATION_FAILED = NOT_SUPPORTED
  succ NOT_SUPPORTED = NOT_FOUND
  succ NOT_FOUND = INSUFFICIENT_FUNDS
  succ INSUFFICIENT_FUNDS = NOT_UNIQUE
  succ (FailureKind'Unrecognized _)
    = Prelude.error
        "FailureKind.succ: bad argument: unrecognized value"
  pred REQUIRED
    = Prelude.error
        "FailureKind.pred: bad argument REQUIRED. This value would be out of bounds."
  pred PARSING_FAILED = REQUIRED
  pred VERIFICATION_FAILED = PARSING_FAILED
  pred NOT_SUPPORTED = VERIFICATION_FAILED
  pred NOT_FOUND = NOT_SUPPORTED
  pred INSUFFICIENT_FUNDS = NOT_FOUND
  pred NOT_UNIQUE = INSUFFICIENT_FUNDS
  pred (FailureKind'Unrecognized _)
    = Prelude.error
        "FailureKind.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault FailureKind where
  fieldDefault = REQUIRED
instance Control.DeepSeq.NFData FailureKind where
  rnf x__ = Prelude.seq x__ ()
instance Text.PrettyPrint.GenericPretty.Out FailureKind
{- | Fields :
     
         * 'Proto.Lsp.Type_Fields.fieldLocation' @:: Lens' InputFailure [Proto.Lsp.Newtype.FieldIndex]@
         * 'Proto.Lsp.Type_Fields.vec'fieldLocation' @:: Lens' InputFailure (Data.Vector.Vector Proto.Lsp.Newtype.FieldIndex)@
         * 'Proto.Lsp.Type_Fields.kind' @:: Lens' InputFailure FailureKind@ -}
data InputFailure
  = InputFailure'_constructor {_InputFailure'fieldLocation :: !(Data.Vector.Vector Proto.Lsp.Newtype.FieldIndex),
                               _InputFailure'kind :: !FailureKind,
                               _InputFailure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show InputFailure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out InputFailure
instance Data.ProtoLens.Field.HasField InputFailure "fieldLocation" [Proto.Lsp.Newtype.FieldIndex] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField InputFailure "vec'fieldLocation" (Data.Vector.Vector Proto.Lsp.Newtype.FieldIndex) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'fieldLocation
           (\ x__ y__ -> x__ {_InputFailure'fieldLocation = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField InputFailure "kind" FailureKind where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _InputFailure'kind (\ x__ y__ -> x__ {_InputFailure'kind = y__}))
        Prelude.id
instance Data.ProtoLens.Message InputFailure where
  messageName _ = Data.Text.pack "Lsp.Type.InputFailure"
  packedMessageDescriptor _
    = "\n\
      \\fInputFailure\DC2>\n\
      \\SOfield_location\CAN\SOH \ETX(\v2\ETB.Lsp.Newtype.FieldIndexR\rfieldLocation\DC2)\n\
      \\EOTkind\CAN\STX \SOH(\SO2\NAK.Lsp.Type.FailureKindR\EOTkind"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fieldLocation__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "field_location"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.FieldIndex)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"fieldLocation")) ::
              Data.ProtoLens.FieldDescriptor InputFailure
        kind__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "kind"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor FailureKind)
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
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.Lsp.Newtype.FieldIndex
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
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\SOlsp/type.proto\DC2\bLsp.Type\SUB\DC1lsp/newtype.proto\"a\n\
    \\ETXCtx\DC2(\n\
    \\ENQnonce\CAN\SOH \SOH(\v2\DC2.Lsp.Newtype.NonceR\ENQnonce\DC20\n\
    \\apub_key\CAN\STX \SOH(\v2\ETB.Lsp.Newtype.NodePubKeyR\ACKpubKey\"q\n\
    \\aFailure\DC2,\n\
    \\ENQinput\CAN\SOH \ETX(\v2\SYN.Lsp.Type.InputFailureR\ENQinput\DC28\n\
    \\binternal\CAN\STX \ETX(\v2\FS.Lsp.Newtype.InternalFailureR\binternal\"y\n\
    \\fInputFailure\DC2>\n\
    \\SOfield_location\CAN\SOH \ETX(\v2\ETB.Lsp.Newtype.FieldIndexR\rfieldLocation\DC2)\n\
    \\EOTkind\CAN\STX \SOH(\SO2\NAK.Lsp.Type.FailureKindR\EOTkind*\146\SOH\n\
    \\vFailureKind\DC2\f\n\
    \\bREQUIRED\DLE\NUL\DC2\DC2\n\
    \\SOPARSING_FAILED\DLE\SOH\DC2\ETB\n\
    \\DC3VERIFICATION_FAILED\DLE\STX\DC2\DC1\n\
    \\rNOT_SUPPORTED\DLE\ETX\DC2\r\n\
    \\tNOT_FOUND\DLE\EOT\DC2\SYN\n\
    \\DC2INSUFFICIENT_FUNDS\DLE\ENQ\DC2\SO\n\
    \\n\
    \NOT_UNIQUE\DLE\ACKJ\205\f\n\
    \\ACK\DC2\EOT\NUL\NUL+\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\SOH\NUL\DC1\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\ETX\NUL\ESC\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ENQ\NUL\b\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ENQ\b\v\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\ACK\STX\US\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\ACK\STX\DC4\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\ACK\NAK\SUB\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\ACK\GS\RS\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\a\STX&\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\a\STX\EM\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\a\SUB!\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\a$%\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\n\
    \\NUL\r\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\n\
    \\b\SI\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\v\STX\"\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\EOT\DC2\ETX\v\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\v\v\ETB\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\v\CAN\GS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\v !\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\f\STX5\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\EOT\DC2\ETX\f\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX\f\v'\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\f(0\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\f34\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\SI\NUL\DC2\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\SI\b\DC4\n\
    \\v\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETX\DLE\STX6\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\EOT\DC2\ETX\DLE\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ACK\DC2\ETX\DLE\v\"\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX\DLE#1\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX\DLE45\n\
    \\v\n\
    \\EOT\EOT\STX\STX\SOH\DC2\ETX\DC1\STX\ETB\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ACK\DC2\ETX\DC1\STX\r\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\SOH\DC2\ETX\DC1\SO\DC2\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\SOH\ETX\DC2\ETX\DC1\NAK\SYN\n\
    \\n\
    \\n\
    \\STX\ENQ\NUL\DC2\EOT\DC4\NUL+\SOH\n\
    \\n\
    \\n\
    \\ETX\ENQ\NUL\SOH\DC2\ETX\DC4\ENQ\DLE\n\
    \l\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\ETX\ETB\STX\SI\SUB_ All proto3 messages are optional, but sometimes\n\
    \ message presence is required by source code.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETX\ETB\STX\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETX\ETB\r\SO\n\
    \\201\SOH\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\ETX\FS\STX\NAK\SUB\187\SOH Sometimes data is required to be in some\n\
    \ specific format (for example DER binary encoding)\n\
    \ which is not the part of proto3 type system.\n\
    \ This error shows the failure of custom parser.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETX\FS\STX\DLE\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETX\FS\DC3\DC4\n\
    \\157\SOH\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\ETX \STX\SUB\SUB\143\SOH Even if custom parser succeeded, sometimes data\n\
    \ needs to be verified somehow, for example\n\
    \ signature needs to be cryptographically verified.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETX \STX\NAK\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETX \CAN\EM\n\
    \N\n\
    \\EOT\ENQ\NUL\STX\ETX\DC2\ETX\"\STX\DC4\SUBA Even verified data might be not supported by source code (yet).\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETX\"\STX\SI\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETX\"\DC2\DC3\n\
    \\182\SOH\n\
    \\EOT\ENQ\NUL\STX\EOT\DC2\ETX&\STX\DLE\SUB\168\SOH Sometimes protobuf term is not data itself, but reference\n\
    \ to some other data, located somewhere else, for example\n\
    \ in database, and this resource might be not found.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\EOT\SOH\DC2\ETX&\STX\v\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\EOT\STX\DC2\ETX&\SO\SI\n\
    \X\n\
    \\EOT\ENQ\NUL\STX\ENQ\DC2\ETX(\STX\EM\SUBK For errors where invoker doesn't have enough funds to perform transaction\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ENQ\SOH\DC2\ETX(\STX\DC4\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ENQ\STX\DC2\ETX(\ETB\CAN\n\
    \O\n\
    \\EOT\ENQ\NUL\STX\ACK\DC2\ETX*\STX\DC1\SUBB If some field provided in request is not unique (but it must be)\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ACK\SOH\DC2\ETX*\STX\f\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ACK\STX\DC2\ETX*\SI\DLEb\ACKproto3"