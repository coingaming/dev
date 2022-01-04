{- This file was auto-generated from lsp/custody/deposit_ln.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Lsp.Custody.DepositLn (
        Request(), Response(), Response'Either(..), _Response'Success',
        _Response'Failure, Response'Success()
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
import qualified Proto.Lsp.Type
{- | Fields :
     
         * 'Proto.Lsp.Custody.DepositLn_Fields.ctx' @:: Lens' Request Proto.Lsp.Type.Ctx@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'ctx' @:: Lens' Request (Prelude.Maybe Proto.Lsp.Type.Ctx)@
         * 'Proto.Lsp.Custody.DepositLn_Fields.msat' @:: Lens' Request Proto.Lsp.Newtype.Msat@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'msat' @:: Lens' Request (Prelude.Maybe Proto.Lsp.Newtype.Msat)@ -}
data Request
  = Request'_constructor {_Request'ctx :: !(Prelude.Maybe Proto.Lsp.Type.Ctx),
                          _Request'msat :: !(Prelude.Maybe Proto.Lsp.Newtype.Msat),
                          _Request'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Request where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Request
instance Data.ProtoLens.Field.HasField Request "ctx" Proto.Lsp.Type.Ctx where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'ctx (\ x__ y__ -> x__ {_Request'ctx = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'ctx" (Prelude.Maybe Proto.Lsp.Type.Ctx) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'ctx (\ x__ y__ -> x__ {_Request'ctx = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Request "msat" Proto.Lsp.Newtype.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'msat (\ x__ y__ -> x__ {_Request'msat = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'msat" (Prelude.Maybe Proto.Lsp.Newtype.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'msat (\ x__ y__ -> x__ {_Request'msat = y__}))
        Prelude.id
instance Data.ProtoLens.Message Request where
  messageName _ = Data.Text.pack "Lsp.Custody.DepositLn.Request"
  packedMessageDescriptor _
    = "\n\
      \\aRequest\DC2\US\n\
      \\ETXctx\CAN\SOH \SOH(\v2\r.Lsp.Type.CtxR\ETXctx\DC2%\n\
      \\EOTmsat\CAN\STX \SOH(\v2\DC1.Lsp.Newtype.MsatR\EOTmsat"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        ctx__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ctx"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Type.Ctx)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'ctx")) ::
              Data.ProtoLens.FieldDescriptor Request
        msat__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "msat"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.Msat)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'msat")) ::
              Data.ProtoLens.FieldDescriptor Request
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, ctx__field_descriptor),
           (Data.ProtoLens.Tag 2, msat__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Request'_unknownFields
        (\ x__ y__ -> x__ {_Request'_unknownFields = y__})
  defMessage
    = Request'_constructor
        {_Request'ctx = Prelude.Nothing, _Request'msat = Prelude.Nothing,
         _Request'_unknownFields = []}
  parseMessage
    = let
        loop :: Request -> Data.ProtoLens.Encoding.Bytes.Parser Request
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
                                       "ctx"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"ctx") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "msat"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"msat") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Request"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'ctx") _x
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
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'msat") _x
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
instance Control.DeepSeq.NFData Request where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Request'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Request'ctx x__)
                (Control.DeepSeq.deepseq (_Request'msat x__) ()))
{- | Fields :
     
         * 'Proto.Lsp.Custody.DepositLn_Fields.ctx' @:: Lens' Response Proto.Lsp.Type.Ctx@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'ctx' @:: Lens' Response (Prelude.Maybe Proto.Lsp.Type.Ctx)@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'either' @:: Lens' Response (Prelude.Maybe Response'Either)@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'success' @:: Lens' Response (Prelude.Maybe Response'Success)@
         * 'Proto.Lsp.Custody.DepositLn_Fields.success' @:: Lens' Response Response'Success@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'failure' @:: Lens' Response (Prelude.Maybe Proto.Lsp.Type.Failure)@
         * 'Proto.Lsp.Custody.DepositLn_Fields.failure' @:: Lens' Response Proto.Lsp.Type.Failure@ -}
data Response
  = Response'_constructor {_Response'ctx :: !(Prelude.Maybe Proto.Lsp.Type.Ctx),
                           _Response'either :: !(Prelude.Maybe Response'Either),
                           _Response'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response
data Response'Either
  = Response'Success' !Response'Success |
    Response'Failure !Proto.Lsp.Type.Failure
  deriving stock (Prelude.Show,
                  Prelude.Eq,
                  Prelude.Ord,
                  GHC.Generics.Generic)
instance Text.PrettyPrint.GenericPretty.Out Response'Either
instance Data.ProtoLens.Field.HasField Response "ctx" Proto.Lsp.Type.Ctx where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'ctx (\ x__ y__ -> x__ {_Response'ctx = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response "maybe'ctx" (Prelude.Maybe Proto.Lsp.Type.Ctx) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'ctx (\ x__ y__ -> x__ {_Response'ctx = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response "maybe'either" (Prelude.Maybe Response'Either) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response "maybe'success" (Prelude.Maybe Response'Success) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Response'Success' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Response'Success' y__))
instance Data.ProtoLens.Field.HasField Response "success" Response'Success where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Response'Success' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Response'Success' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Field.HasField Response "maybe'failure" (Prelude.Maybe Proto.Lsp.Type.Failure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Response'Failure x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Response'Failure y__))
instance Data.ProtoLens.Field.HasField Response "failure" Proto.Lsp.Type.Failure where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Response'Failure x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Response'Failure y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message Response where
  messageName _ = Data.Text.pack "Lsp.Custody.DepositLn.Response"
  packedMessageDescriptor _
    = "\n\
      \\bResponse\DC2\US\n\
      \\ETXctx\CAN\SOH \SOH(\v2\r.Lsp.Type.CtxR\ETXctx\DC2C\n\
      \\asuccess\CAN\STX \SOH(\v2'.Lsp.Custody.DepositLn.Response.SuccessH\NULR\asuccess\DC2-\n\
      \\afailure\CAN\ETX \SOH(\v2\DC1.Lsp.Type.FailureH\NULR\afailure\SUB;\n\
      \\aSuccess\DC20\n\
      \\ainvoice\CAN\SOH \SOH(\v2\SYN.Lsp.Newtype.LnInvoiceR\ainvoiceB\b\n\
      \\ACKeither"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        ctx__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ctx"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Type.Ctx)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'ctx")) ::
              Data.ProtoLens.FieldDescriptor Response
        success__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "success"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Response'Success)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'success")) ::
              Data.ProtoLens.FieldDescriptor Response
        failure__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "failure"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Type.Failure)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'failure")) ::
              Data.ProtoLens.FieldDescriptor Response
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, ctx__field_descriptor),
           (Data.ProtoLens.Tag 2, success__field_descriptor),
           (Data.ProtoLens.Tag 3, failure__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'_unknownFields
        (\ x__ y__ -> x__ {_Response'_unknownFields = y__})
  defMessage
    = Response'_constructor
        {_Response'ctx = Prelude.Nothing,
         _Response'either = Prelude.Nothing, _Response'_unknownFields = []}
  parseMessage
    = let
        loop :: Response -> Data.ProtoLens.Encoding.Bytes.Parser Response
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
                                       "ctx"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"ctx") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "success"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"success") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "failure"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"failure") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Response"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'ctx") _x
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
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'either") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just (Response'Success' v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage
                             v)
                   (Prelude.Just (Response'Failure v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage
                             v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Response where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Response'ctx x__)
                (Control.DeepSeq.deepseq (_Response'either x__) ()))
instance Control.DeepSeq.NFData Response'Either where
  rnf (Response'Success' x__) = Control.DeepSeq.rnf x__
  rnf (Response'Failure x__) = Control.DeepSeq.rnf x__
_Response'Success' ::
  Data.ProtoLens.Prism.Prism' Response'Either Response'Success
_Response'Success'
  = Data.ProtoLens.Prism.prism'
      Response'Success'
      (\ p__
         -> case p__ of
              (Response'Success' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Response'Failure ::
  Data.ProtoLens.Prism.Prism' Response'Either Proto.Lsp.Type.Failure
_Response'Failure
  = Data.ProtoLens.Prism.prism'
      Response'Failure
      (\ p__
         -> case p__ of
              (Response'Failure p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.Lsp.Custody.DepositLn_Fields.invoice' @:: Lens' Response'Success Proto.Lsp.Newtype.LnInvoice@
         * 'Proto.Lsp.Custody.DepositLn_Fields.maybe'invoice' @:: Lens' Response'Success (Prelude.Maybe Proto.Lsp.Newtype.LnInvoice)@ -}
data Response'Success
  = Response'Success'_constructor {_Response'Success'invoice :: !(Prelude.Maybe Proto.Lsp.Newtype.LnInvoice),
                                   _Response'Success'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Success where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Success
instance Data.ProtoLens.Field.HasField Response'Success "invoice" Proto.Lsp.Newtype.LnInvoice where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'invoice
           (\ x__ y__ -> x__ {_Response'Success'invoice = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response'Success "maybe'invoice" (Prelude.Maybe Proto.Lsp.Newtype.LnInvoice) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'invoice
           (\ x__ y__ -> x__ {_Response'Success'invoice = y__}))
        Prelude.id
instance Data.ProtoLens.Message Response'Success where
  messageName _
    = Data.Text.pack "Lsp.Custody.DepositLn.Response.Success"
  packedMessageDescriptor _
    = "\n\
      \\aSuccess\DC20\n\
      \\ainvoice\CAN\SOH \SOH(\v2\SYN.Lsp.Newtype.LnInvoiceR\ainvoice"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        invoice__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "invoice"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.Lsp.Newtype.LnInvoice)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'invoice")) ::
              Data.ProtoLens.FieldDescriptor Response'Success
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, invoice__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Success'_unknownFields
        (\ x__ y__ -> x__ {_Response'Success'_unknownFields = y__})
  defMessage
    = Response'Success'_constructor
        {_Response'Success'invoice = Prelude.Nothing,
         _Response'Success'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Response'Success
          -> Data.ProtoLens.Encoding.Bytes.Parser Response'Success
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
                                       "invoice"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"invoice") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "Success"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'invoice") _x
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
instance Control.DeepSeq.NFData Response'Success where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'Success'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Response'Success'invoice x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\FSlsp/custody/deposit_ln.proto\DC2\NAKLsp.Custody.DepositLn\SUB\DC1lsp/newtype.proto\SUB\SOlsp/type.proto\"Q\n\
    \\aRequest\DC2\US\n\
    \\ETXctx\CAN\SOH \SOH(\v2\r.Lsp.Type.CtxR\ETXctx\DC2%\n\
    \\EOTmsat\CAN\STX \SOH(\v2\DC1.Lsp.Newtype.MsatR\EOTmsat\"\230\SOH\n\
    \\bResponse\DC2\US\n\
    \\ETXctx\CAN\SOH \SOH(\v2\r.Lsp.Type.CtxR\ETXctx\DC2C\n\
    \\asuccess\CAN\STX \SOH(\v2'.Lsp.Custody.DepositLn.Response.SuccessH\NULR\asuccess\DC2-\n\
    \\afailure\CAN\ETX \SOH(\v2\DC1.Lsp.Type.FailureH\NULR\afailure\SUB;\n\
    \\aSuccess\DC20\n\
    \\ainvoice\CAN\SOH \SOH(\v2\SYN.Lsp.Newtype.LnInvoiceR\ainvoiceB\b\n\
    \\ACKeitherJ\236\ETX\n\
    \\ACK\DC2\EOT\NUL\NUL\SYN\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\SOH\NUL\RS\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\ETX\NUL\ESC\n\
    \\t\n\
    \\STX\ETX\SOH\DC2\ETX\EOT\NUL\CAN\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ACK\NUL\t\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ACK\b\SI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\a\STX\CAN\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\a\STX\SI\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\a\DLE\DC3\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\a\SYN\ETB\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\b\STX\GS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\b\STX\DC3\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\b\DC4\CAN\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\b\ESC\FS\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\v\NUL\SYN\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\v\b\DLE\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\f\STX\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\f\STX\SI\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\f\DLE\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\f\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\SOH\b\NUL\DC2\EOT\SO\STX\DC1\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\b\NUL\SOH\DC2\ETX\SO\b\SO\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\SI\EOT\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX\SI\EOT\v\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\SI\f\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\SI\SYN\ETB\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX\DLE\EOT\"\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ACK\DC2\ETX\DLE\EOT\NAK\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX\DLE\SYN\GS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX\DLE !\n\
    \\f\n\
    \\EOT\EOT\SOH\ETX\NUL\DC2\EOT\DC3\STX\NAK\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\NUL\SOH\DC2\ETX\DC3\n\
    \\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\NUL\DC2\ETX\DC4\EOT'\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ACK\DC2\ETX\DC4\EOT\SUB\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\SOH\DC2\ETX\DC4\ESC\"\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ETX\DC2\ETX\DC4%&b\ACKproto3"