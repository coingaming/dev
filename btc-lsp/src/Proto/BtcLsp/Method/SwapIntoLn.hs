{- This file was auto-generated from btc_lsp/method/swap_into_ln.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Method.SwapIntoLn (
        Request(), Response(), Response'Either(..), _Response'Success',
        _Response'Failure', Response'Failure(),
        Response'Failure'InputFailure(..), Response'Failure'InputFailure(),
        Response'Failure'InputFailure'UnrecognizedValue, Response'Success()
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
import qualified Proto.BtcLsp.Data.HighLevel
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.ctx' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.Ctx@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'ctx' @:: Lens' Request (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.refundOnChainAddress' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'refundOnChainAddress' @:: Lens' Request (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.privacy' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.Privacy@ -}
data Request
  = Request'_constructor {_Request'ctx :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx),
                          _Request'refundOnChainAddress :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress),
                          _Request'privacy :: !Proto.BtcLsp.Data.HighLevel.Privacy,
                          _Request'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Request where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Request
instance Data.ProtoLens.Field.HasField Request "ctx" Proto.BtcLsp.Data.HighLevel.Ctx where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'ctx (\ x__ y__ -> x__ {_Request'ctx = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'ctx" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'ctx (\ x__ y__ -> x__ {_Request'ctx = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Request "refundOnChainAddress" Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'refundOnChainAddress
           (\ x__ y__ -> x__ {_Request'refundOnChainAddress = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'refundOnChainAddress" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'refundOnChainAddress
           (\ x__ y__ -> x__ {_Request'refundOnChainAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Request "privacy" Proto.BtcLsp.Data.HighLevel.Privacy where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'privacy (\ x__ y__ -> x__ {_Request'privacy = y__}))
        Prelude.id
instance Data.ProtoLens.Message Request where
  messageName _ = Data.Text.pack "BtcLsp.Method.SwapIntoLn.Request"
  packedMessageDescriptor _
    = "\n\
      \\aRequest\DC2,\n\
      \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2b\n\
      \\ETBrefund_on_chain_address\CAN\ETX \SOH(\v2+.BtcLsp.Data.HighLevel.RefundOnChainAddressR\DC4refundOnChainAddress\DC28\n\
      \\aprivacy\CAN\EOT \SOH(\SO2\RS.BtcLsp.Data.HighLevel.PrivacyR\aprivacy"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        ctx__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ctx"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.Ctx)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'ctx")) ::
              Data.ProtoLens.FieldDescriptor Request
        refundOnChainAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "refund_on_chain_address"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.RefundOnChainAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'refundOnChainAddress")) ::
              Data.ProtoLens.FieldDescriptor Request
        privacy__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "privacy"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.Privacy)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"privacy")) ::
              Data.ProtoLens.FieldDescriptor Request
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, ctx__field_descriptor),
           (Data.ProtoLens.Tag 3, refundOnChainAddress__field_descriptor),
           (Data.ProtoLens.Tag 4, privacy__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Request'_unknownFields
        (\ x__ y__ -> x__ {_Request'_unknownFields = y__})
  defMessage
    = Request'_constructor
        {_Request'ctx = Prelude.Nothing,
         _Request'refundOnChainAddress = Prelude.Nothing,
         _Request'privacy = Data.ProtoLens.fieldDefault,
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
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "refund_on_chain_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"refundOnChainAddress") y x)
                        32
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (Prelude.fmap
                                          Prelude.toEnum
                                          (Prelude.fmap
                                             Prelude.fromIntegral
                                             Data.ProtoLens.Encoding.Bytes.getVarInt))
                                       "privacy"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"privacy") y x)
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
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'refundOnChainAddress") _x
                 of
                   Prelude.Nothing -> Data.Monoid.mempty
                   (Prelude.Just _v)
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage _v))
                ((Data.Monoid.<>)
                   (let
                      _v = Lens.Family2.view (Data.ProtoLens.Field.field @"privacy") _x
                    in
                      if (Prelude.==) _v Data.ProtoLens.fieldDefault then
                          Data.Monoid.mempty
                      else
                          (Data.Monoid.<>)
                            (Data.ProtoLens.Encoding.Bytes.putVarInt 32)
                            ((Prelude..)
                               ((Prelude..)
                                  Data.ProtoLens.Encoding.Bytes.putVarInt Prelude.fromIntegral)
                               Prelude.fromEnum _v))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Request where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Request'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Request'ctx x__)
                (Control.DeepSeq.deepseq
                   (_Request'refundOnChainAddress x__)
                   (Control.DeepSeq.deepseq (_Request'privacy x__) ())))
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.ctx' @:: Lens' Response Proto.BtcLsp.Data.HighLevel.Ctx@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'ctx' @:: Lens' Response (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'either' @:: Lens' Response (Prelude.Maybe Response'Either)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'success' @:: Lens' Response (Prelude.Maybe Response'Success)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.success' @:: Lens' Response Response'Success@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'failure' @:: Lens' Response (Prelude.Maybe Response'Failure)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.failure' @:: Lens' Response Response'Failure@ -}
data Response
  = Response'_constructor {_Response'ctx :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx),
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
    Response'Failure' !Response'Failure
  deriving stock (Prelude.Show,
                  Prelude.Eq,
                  Prelude.Ord,
                  GHC.Generics.Generic)
instance Text.PrettyPrint.GenericPretty.Out Response'Either
instance Data.ProtoLens.Field.HasField Response "ctx" Proto.BtcLsp.Data.HighLevel.Ctx where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'ctx (\ x__ y__ -> x__ {_Response'ctx = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response "maybe'ctx" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx) where
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
instance Data.ProtoLens.Field.HasField Response "maybe'failure" (Prelude.Maybe Response'Failure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        (Lens.Family2.Unchecked.lens
           (\ x__
              -> case x__ of
                   (Prelude.Just (Response'Failure' x__val)) -> Prelude.Just x__val
                   _otherwise -> Prelude.Nothing)
           (\ _ y__ -> Prelude.fmap Response'Failure' y__))
instance Data.ProtoLens.Field.HasField Response "failure" Response'Failure where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'either (\ x__ y__ -> x__ {_Response'either = y__}))
        ((Prelude..)
           (Lens.Family2.Unchecked.lens
              (\ x__
                 -> case x__ of
                      (Prelude.Just (Response'Failure' x__val)) -> Prelude.Just x__val
                      _otherwise -> Prelude.Nothing)
              (\ _ y__ -> Prelude.fmap Response'Failure' y__))
           (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage))
instance Data.ProtoLens.Message Response where
  messageName _ = Data.Text.pack "BtcLsp.Method.SwapIntoLn.Response"
  packedMessageDescriptor _
    = "\n\
      \\bResponse\DC2,\n\
      \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2F\n\
      \\asuccess\CAN\STX \SOH(\v2*.BtcLsp.Method.SwapIntoLn.Response.SuccessH\NULR\asuccess\DC2F\n\
      \\afailure\CAN\ETX \SOH(\v2*.BtcLsp.Method.SwapIntoLn.Response.FailureH\NULR\afailure\SUB\175\SOH\n\
      \\aSuccess\DC2\\\n\
      \\NAKfund_on_chain_address\CAN\SOH \SOH(\v2).BtcLsp.Data.HighLevel.FundOnChainAddressR\DC2fundOnChainAddress\DC2F\n\
      \\SOmin_fund_money\CAN\STX \SOH(\v2 .BtcLsp.Data.HighLevel.FundMoneyR\fminFundMoney\SUB\211\STX\n\
      \\aFailure\DC2=\n\
      \\ageneric\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ageneric\DC2S\n\
      \\bspecific\CAN\STX \ETX(\SO27.BtcLsp.Method.SwapIntoLn.Response.Failure.InputFailureR\bspecific\DC2B\n\
      \\binternal\CAN\ETX \ETX(\v2&.BtcLsp.Data.HighLevel.InternalFailureR\binternal\"p\n\
      \\fInputFailure\DC2\v\n\
      \\aDEFAULT\DLE\NUL\DC2(\n\
      \$REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID\DLE\ETX\DC2)\n\
      \%REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT\DLE\EOTB\b\n\
      \\ACKeither"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        ctx__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "ctx"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.Ctx)
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
                 Data.ProtoLens.FieldTypeDescriptor Response'Failure)
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
                          Data.ProtoLens.encodeMessage _v))
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
                             Data.ProtoLens.encodeMessage v)
                   (Prelude.Just (Response'Failure' v))
                     -> (Data.Monoid.<>)
                          (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                          ((Prelude..)
                             (\ bs
                                -> (Data.Monoid.<>)
                                     (Data.ProtoLens.Encoding.Bytes.putVarInt
                                        (Prelude.fromIntegral (Data.ByteString.length bs)))
                                     (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                             Data.ProtoLens.encodeMessage v))
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
  rnf (Response'Failure' x__) = Control.DeepSeq.rnf x__
_Response'Success' ::
  Data.ProtoLens.Prism.Prism' Response'Either Response'Success
_Response'Success'
  = Data.ProtoLens.Prism.prism'
      Response'Success'
      (\ p__
         -> case p__ of
              (Response'Success' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
_Response'Failure' ::
  Data.ProtoLens.Prism.Prism' Response'Either Response'Failure
_Response'Failure'
  = Data.ProtoLens.Prism.prism'
      Response'Failure'
      (\ p__
         -> case p__ of
              (Response'Failure' p__val) -> Prelude.Just p__val
              _otherwise -> Prelude.Nothing)
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.generic' @:: Lens' Response'Failure [Proto.BtcLsp.Data.HighLevel.InputFailure]@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.vec'generic' @:: Lens' Response'Failure (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.specific' @:: Lens' Response'Failure [Response'Failure'InputFailure]@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.vec'specific' @:: Lens' Response'Failure (Data.Vector.Vector Response'Failure'InputFailure)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.internal' @:: Lens' Response'Failure [Proto.BtcLsp.Data.HighLevel.InternalFailure]@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.vec'internal' @:: Lens' Response'Failure (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InternalFailure)@ -}
data Response'Failure
  = Response'Failure'_constructor {_Response'Failure'generic :: !(Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure),
                                   _Response'Failure'specific :: !(Data.Vector.Vector Response'Failure'InputFailure),
                                   _Response'Failure'internal :: !(Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InternalFailure),
                                   _Response'Failure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Failure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Failure
instance Data.ProtoLens.Field.HasField Response'Failure "generic" [Proto.BtcLsp.Data.HighLevel.InputFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'generic
           (\ x__ y__ -> x__ {_Response'Failure'generic = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Response'Failure "vec'generic" (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'generic
           (\ x__ y__ -> x__ {_Response'Failure'generic = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response'Failure "specific" [Response'Failure'InputFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'specific
           (\ x__ y__ -> x__ {_Response'Failure'specific = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Response'Failure "vec'specific" (Data.Vector.Vector Response'Failure'InputFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'specific
           (\ x__ y__ -> x__ {_Response'Failure'specific = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response'Failure "internal" [Proto.BtcLsp.Data.HighLevel.InternalFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'internal
           (\ x__ y__ -> x__ {_Response'Failure'internal = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Response'Failure "vec'internal" (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InternalFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'internal
           (\ x__ y__ -> x__ {_Response'Failure'internal = y__}))
        Prelude.id
instance Data.ProtoLens.Message Response'Failure where
  messageName _
    = Data.Text.pack "BtcLsp.Method.SwapIntoLn.Response.Failure"
  packedMessageDescriptor _
    = "\n\
      \\aFailure\DC2=\n\
      \\ageneric\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ageneric\DC2S\n\
      \\bspecific\CAN\STX \ETX(\SO27.BtcLsp.Method.SwapIntoLn.Response.Failure.InputFailureR\bspecific\DC2B\n\
      \\binternal\CAN\ETX \ETX(\v2&.BtcLsp.Data.HighLevel.InternalFailureR\binternal\"p\n\
      \\fInputFailure\DC2\v\n\
      \\aDEFAULT\DLE\NUL\DC2(\n\
      \$REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID\DLE\ETX\DC2)\n\
      \%REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT\DLE\EOT"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        generic__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "generic"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.InputFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"generic")) ::
              Data.ProtoLens.FieldDescriptor Response'Failure
        specific__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "specific"
              (Data.ProtoLens.ScalarField Data.ProtoLens.EnumField ::
                 Data.ProtoLens.FieldTypeDescriptor Response'Failure'InputFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Packed (Data.ProtoLens.Field.field @"specific")) ::
              Data.ProtoLens.FieldDescriptor Response'Failure
        internal__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "internal"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.InternalFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"internal")) ::
              Data.ProtoLens.FieldDescriptor Response'Failure
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, generic__field_descriptor),
           (Data.ProtoLens.Tag 2, specific__field_descriptor),
           (Data.ProtoLens.Tag 3, internal__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Failure'_unknownFields
        (\ x__ y__ -> x__ {_Response'Failure'_unknownFields = y__})
  defMessage
    = Response'Failure'_constructor
        {_Response'Failure'generic = Data.Vector.Generic.empty,
         _Response'Failure'specific = Data.Vector.Generic.empty,
         _Response'Failure'internal = Data.Vector.Generic.empty,
         _Response'Failure'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Response'Failure
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.BtcLsp.Data.HighLevel.InputFailure
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.BtcLsp.Data.HighLevel.InternalFailure
                -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Response'Failure'InputFailure
                   -> Data.ProtoLens.Encoding.Bytes.Parser Response'Failure
        loop x mutable'generic mutable'internal mutable'specific
          = do end <- Data.ProtoLens.Encoding.Bytes.atEnd
               if end then
                   do frozen'generic <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                          (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                             mutable'generic)
                      frozen'internal <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                              mutable'internal)
                      frozen'specific <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                           (Data.ProtoLens.Encoding.Growing.unsafeFreeze
                                              mutable'specific)
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
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'generic") frozen'generic
                              (Lens.Family2.set
                                 (Data.ProtoLens.Field.field @"vec'internal") frozen'internal
                                 (Lens.Family2.set
                                    (Data.ProtoLens.Field.field @"vec'specific") frozen'specific
                                    x))))
               else
                   do tag <- Data.ProtoLens.Encoding.Bytes.getVarInt
                      case tag of
                        10
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "generic"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'generic y)
                                loop x v mutable'internal mutable'specific
                        16
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (Prelude.fmap
                                           Prelude.toEnum
                                           (Prelude.fmap
                                              Prelude.fromIntegral
                                              Data.ProtoLens.Encoding.Bytes.getVarInt))
                                        "specific"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'specific y)
                                loop x mutable'generic mutable'internal v
                        18
                          -> do y <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                        Data.ProtoLens.Encoding.Bytes.isolate
                                          (Prelude.fromIntegral len)
                                          ((let
                                              ploop qs
                                                = do packedEnd <- Data.ProtoLens.Encoding.Bytes.atEnd
                                                     if packedEnd then
                                                         Prelude.return qs
                                                     else
                                                         do !q <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                                                    (Prelude.fmap
                                                                       Prelude.toEnum
                                                                       (Prelude.fmap
                                                                          Prelude.fromIntegral
                                                                          Data.ProtoLens.Encoding.Bytes.getVarInt))
                                                                    "specific"
                                                            qs' <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                                                     (Data.ProtoLens.Encoding.Growing.append
                                                                        qs q)
                                                            ploop qs'
                                            in ploop)
                                             mutable'specific)
                                loop x mutable'generic mutable'internal y
                        26
                          -> do !y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                        (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                            Data.ProtoLens.Encoding.Bytes.isolate
                                              (Prelude.fromIntegral len)
                                              Data.ProtoLens.parseMessage)
                                        "internal"
                                v <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                       (Data.ProtoLens.Encoding.Growing.append mutable'internal y)
                                loop x mutable'generic v mutable'specific
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
                                  mutable'generic mutable'internal mutable'specific
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do mutable'generic <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                   Data.ProtoLens.Encoding.Growing.new
              mutable'internal <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                    Data.ProtoLens.Encoding.Growing.new
              mutable'specific <- Data.ProtoLens.Encoding.Parser.Unsafe.unsafeLiftIO
                                    Data.ProtoLens.Encoding.Growing.new
              loop
                Data.ProtoLens.defMessage mutable'generic mutable'internal
                mutable'specific)
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
                           Data.ProtoLens.encodeMessage _v))
                (Lens.Family2.view (Data.ProtoLens.Field.field @"vec'generic") _x))
             ((Data.Monoid.<>)
                (let
                   p = Lens.Family2.view
                         (Data.ProtoLens.Field.field @"vec'specific") _x
                 in
                   if Data.Vector.Generic.null p then
                       Data.Monoid.mempty
                   else
                       (Data.Monoid.<>)
                         (Data.ProtoLens.Encoding.Bytes.putVarInt 18)
                         ((\ bs
                             -> (Data.Monoid.<>)
                                  (Data.ProtoLens.Encoding.Bytes.putVarInt
                                     (Prelude.fromIntegral (Data.ByteString.length bs)))
                                  (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                            (Data.ProtoLens.Encoding.Bytes.runBuilder
                               (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                                  ((Prelude..)
                                     ((Prelude..)
                                        Data.ProtoLens.Encoding.Bytes.putVarInt
                                        Prelude.fromIntegral)
                                     Prelude.fromEnum)
                                  p))))
                ((Data.Monoid.<>)
                   (Data.ProtoLens.Encoding.Bytes.foldMapBuilder
                      (\ _v
                         -> (Data.Monoid.<>)
                              (Data.ProtoLens.Encoding.Bytes.putVarInt 26)
                              ((Prelude..)
                                 (\ bs
                                    -> (Data.Monoid.<>)
                                         (Data.ProtoLens.Encoding.Bytes.putVarInt
                                            (Prelude.fromIntegral (Data.ByteString.length bs)))
                                         (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                                 Data.ProtoLens.encodeMessage _v))
                      (Lens.Family2.view
                         (Data.ProtoLens.Field.field @"vec'internal") _x))
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData Response'Failure where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'Failure'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Response'Failure'generic x__)
                (Control.DeepSeq.deepseq
                   (_Response'Failure'specific x__)
                   (Control.DeepSeq.deepseq (_Response'Failure'internal x__) ())))
newtype Response'Failure'InputFailure'UnrecognizedValue
  = Response'Failure'InputFailure'UnrecognizedValue Data.Int.Int32
  deriving stock (Prelude.Eq,
                  Prelude.Ord,
                  Prelude.Show,
                  GHC.Generics.Generic)
instance Text.PrettyPrint.GenericPretty.Out Response'Failure'InputFailure'UnrecognizedValue
data Response'Failure'InputFailure
  = Response'Failure'DEFAULT |
    Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID |
    Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT |
    Response'Failure'InputFailure'Unrecognized !Response'Failure'InputFailure'UnrecognizedValue
  deriving stock (Prelude.Show,
                  Prelude.Eq,
                  Prelude.Ord,
                  GHC.Generics.Generic)
instance Data.ProtoLens.MessageEnum Response'Failure'InputFailure where
  maybeToEnum 0 = Prelude.Just Response'Failure'DEFAULT
  maybeToEnum 3
    = Prelude.Just
        Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
  maybeToEnum 4
    = Prelude.Just
        Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
  maybeToEnum k
    = Prelude.Just
        (Response'Failure'InputFailure'Unrecognized
           (Response'Failure'InputFailure'UnrecognizedValue
              (Prelude.fromIntegral k)))
  showEnum Response'Failure'DEFAULT = "DEFAULT"
  showEnum Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
    = "REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID"
  showEnum Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
    = "REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT"
  showEnum
    (Response'Failure'InputFailure'Unrecognized (Response'Failure'InputFailure'UnrecognizedValue k))
    = Prelude.show k
  readEnum k
    | (Prelude.==) k "DEFAULT" = Prelude.Just Response'Failure'DEFAULT
    | (Prelude.==) k "REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID"
    = Prelude.Just
        Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
    | (Prelude.==) k "REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT"
    = Prelude.Just
        Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
    | Prelude.otherwise
    = (Prelude.>>=) (Text.Read.readMaybe k) Data.ProtoLens.maybeToEnum
instance Prelude.Bounded Response'Failure'InputFailure where
  minBound = Response'Failure'DEFAULT
  maxBound = Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
instance Prelude.Enum Response'Failure'InputFailure where
  toEnum k__
    = Prelude.maybe
        (Prelude.error
           ((Prelude.++)
              "toEnum: unknown value for enum InputFailure: "
              (Prelude.show k__)))
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
  fromEnum Response'Failure'DEFAULT = 0
  fromEnum Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID = 3
  fromEnum Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT = 4
  fromEnum
    (Response'Failure'InputFailure'Unrecognized (Response'Failure'InputFailure'UnrecognizedValue k))
    = Prelude.fromIntegral k
  succ Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
    = Prelude.error
        "Response'Failure'InputFailure.succ: bad argument Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT. This value would be out of bounds."
  succ Response'Failure'DEFAULT
    = Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
  succ Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
    = Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
  succ (Response'Failure'InputFailure'Unrecognized _)
    = Prelude.error
        "Response'Failure'InputFailure.succ: bad argument: unrecognized value"
  pred Response'Failure'DEFAULT
    = Prelude.error
        "Response'Failure'InputFailure.pred: bad argument Response'Failure'DEFAULT. This value would be out of bounds."
  pred Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
    = Response'Failure'DEFAULT
  pred Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT
    = Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID
  pred (Response'Failure'InputFailure'Unrecognized _)
    = Prelude.error
        "Response'Failure'InputFailure.pred: bad argument: unrecognized value"
  enumFrom = Data.ProtoLens.Message.Enum.messageEnumFrom
  enumFromTo = Data.ProtoLens.Message.Enum.messageEnumFromTo
  enumFromThen = Data.ProtoLens.Message.Enum.messageEnumFromThen
  enumFromThenTo = Data.ProtoLens.Message.Enum.messageEnumFromThenTo
instance Data.ProtoLens.FieldDefault Response'Failure'InputFailure where
  fieldDefault = Response'Failure'DEFAULT
instance Control.DeepSeq.NFData Response'Failure'InputFailure where
  rnf x__ = Prelude.seq x__ ()
instance Text.PrettyPrint.GenericPretty.Out Response'Failure'InputFailure
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.fundOnChainAddress' @:: Lens' Response'Success Proto.BtcLsp.Data.HighLevel.FundOnChainAddress@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'fundOnChainAddress' @:: Lens' Response'Success (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress)@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.minFundMoney' @:: Lens' Response'Success Proto.BtcLsp.Data.HighLevel.FundMoney@
         * 'Proto.BtcLsp.Method.SwapIntoLn_Fields.maybe'minFundMoney' @:: Lens' Response'Success (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundMoney)@ -}
data Response'Success
  = Response'Success'_constructor {_Response'Success'fundOnChainAddress :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress),
                                   _Response'Success'minFundMoney :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundMoney),
                                   _Response'Success'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Success where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Success
instance Data.ProtoLens.Field.HasField Response'Success "fundOnChainAddress" Proto.BtcLsp.Data.HighLevel.FundOnChainAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'fundOnChainAddress
           (\ x__ y__ -> x__ {_Response'Success'fundOnChainAddress = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response'Success "maybe'fundOnChainAddress" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'fundOnChainAddress
           (\ x__ y__ -> x__ {_Response'Success'fundOnChainAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response'Success "minFundMoney" Proto.BtcLsp.Data.HighLevel.FundMoney where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'minFundMoney
           (\ x__ y__ -> x__ {_Response'Success'minFundMoney = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response'Success "maybe'minFundMoney" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundMoney) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'minFundMoney
           (\ x__ y__ -> x__ {_Response'Success'minFundMoney = y__}))
        Prelude.id
instance Data.ProtoLens.Message Response'Success where
  messageName _
    = Data.Text.pack "BtcLsp.Method.SwapIntoLn.Response.Success"
  packedMessageDescriptor _
    = "\n\
      \\aSuccess\DC2\\\n\
      \\NAKfund_on_chain_address\CAN\SOH \SOH(\v2).BtcLsp.Data.HighLevel.FundOnChainAddressR\DC2fundOnChainAddress\DC2F\n\
      \\SOmin_fund_money\CAN\STX \SOH(\v2 .BtcLsp.Data.HighLevel.FundMoneyR\fminFundMoney"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fundOnChainAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "fund_on_chain_address"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.FundOnChainAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fundOnChainAddress")) ::
              Data.ProtoLens.FieldDescriptor Response'Success
        minFundMoney__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "min_fund_money"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.FundMoney)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'minFundMoney")) ::
              Data.ProtoLens.FieldDescriptor Response'Success
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, fundOnChainAddress__field_descriptor),
           (Data.ProtoLens.Tag 2, minFundMoney__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Success'_unknownFields
        (\ x__ y__ -> x__ {_Response'Success'_unknownFields = y__})
  defMessage
    = Response'Success'_constructor
        {_Response'Success'fundOnChainAddress = Prelude.Nothing,
         _Response'Success'minFundMoney = Prelude.Nothing,
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
                                       "fund_on_chain_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"fundOnChainAddress") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "min_fund_money"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"minFundMoney") y x)
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
                  Lens.Family2.view
                    (Data.ProtoLens.Field.field @"maybe'fundOnChainAddress") _x
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
                          Data.ProtoLens.encodeMessage _v))
             ((Data.Monoid.<>)
                (case
                     Lens.Family2.view
                       (Data.ProtoLens.Field.field @"maybe'minFundMoney") _x
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
                             Data.ProtoLens.encodeMessage _v))
                (Data.ProtoLens.Encoding.Wire.buildFieldSet
                   (Lens.Family2.view Data.ProtoLens.unknownFields _x)))
instance Control.DeepSeq.NFData Response'Success where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'Success'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Response'Success'fundOnChainAddress x__)
                (Control.DeepSeq.deepseq (_Response'Success'minFundMoney x__) ()))
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \!btc_lsp/method/swap_into_ln.proto\DC2\CANBtcLsp.Method.SwapIntoLn\SUB\GSbtc_lsp/data/high_level.proto\"\213\SOH\n\
    \\aRequest\DC2,\n\
    \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2b\n\
    \\ETBrefund_on_chain_address\CAN\ETX \SOH(\v2+.BtcLsp.Data.HighLevel.RefundOnChainAddressR\DC4refundOnChainAddress\DC28\n\
    \\aprivacy\CAN\EOT \SOH(\SO2\RS.BtcLsp.Data.HighLevel.PrivacyR\aprivacy\"\218\ENQ\n\
    \\bResponse\DC2,\n\
    \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2F\n\
    \\asuccess\CAN\STX \SOH(\v2*.BtcLsp.Method.SwapIntoLn.Response.SuccessH\NULR\asuccess\DC2F\n\
    \\afailure\CAN\ETX \SOH(\v2*.BtcLsp.Method.SwapIntoLn.Response.FailureH\NULR\afailure\SUB\175\SOH\n\
    \\aSuccess\DC2\\\n\
    \\NAKfund_on_chain_address\CAN\SOH \SOH(\v2).BtcLsp.Data.HighLevel.FundOnChainAddressR\DC2fundOnChainAddress\DC2F\n\
    \\SOmin_fund_money\CAN\STX \SOH(\v2 .BtcLsp.Data.HighLevel.FundMoneyR\fminFundMoney\SUB\211\STX\n\
    \\aFailure\DC2=\n\
    \\ageneric\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ageneric\DC2S\n\
    \\bspecific\CAN\STX \ETX(\SO27.BtcLsp.Method.SwapIntoLn.Response.Failure.InputFailureR\bspecific\DC2B\n\
    \\binternal\CAN\ETX \ETX(\v2&.BtcLsp.Data.HighLevel.InternalFailureR\binternal\"p\n\
    \\fInputFailure\DC2\v\n\
    \\aDEFAULT\DLE\NUL\DC2(\n\
    \$REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID\DLE\ETX\DC2)\n\
    \%REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT\DLE\EOTB\b\n\
    \\ACKeitherJ\149\SO\n\
    \\ACK\DC2\EOT\NUL\NUL8\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\STX\NUL!\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\EOT\NUL'\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ACK\NUL\DC4\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\ACK\b\SI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\a\STX%\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\a\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\a\GS \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\a#$\n\
    \\166\ETX\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\DC2\STXJ\SUB\152\ETX\n\
    \ NOTE : Removed as redundant data after adopting\n\
    \ psbt-based channel opening procedure. Before there wasn't\n\
    \ much control over UTXOs, so it was not possible to safely\n\
    \ use push_sat, so fund_ln_invoice was a workaround used to\n\
    \ push liquidity. With precise UTXO control this is not\n\
    \ the issue anymore, bitcoin network solves double spend\n\
    \ problem.\n\
    \\n\
    \ .BtcLsp.Data.HighLevel.FundLnInvoice fund_ln_invoice = 2;\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\DC2\STX-\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\DC2.E\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\DC2HI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\STX\DC2\ETX\DC3\STX-\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\ETX\DC3\STX \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETX\DC3!(\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETX\DC3+,\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\SYN\NUL8\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\SYN\b\DLE\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\ETB\STX%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\ETB\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\ETB\GS \n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\ETB#$\n\
    \\f\n\
    \\EOT\EOT\SOH\b\NUL\DC2\EOT\EM\STX\FS\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\b\NUL\SOH\DC2\ETX\EM\b\SO\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\SUB\EOT\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX\SUB\EOT\v\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\SUB\f\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\SUB\SYN\ETB\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX\ESC\EOT\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ACK\DC2\ETX\ESC\EOT\v\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX\ESC\f\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX\ESC\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\SOH\ETX\NUL\DC2\EOT\RS\STX#\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\NUL\SOH\DC2\ETX\RS\n\
    \\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\NUL\DC2\ETX\US\EOTH\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ACK\DC2\ETX\US\EOT-\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\SOH\DC2\ETX\US.C\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ETX\DC2\ETX\USFG\n\
    \{\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\SOH\DC2\ETX\"\EOT8\SUBl Minimal expected swap amount. Swap will not happen\n\
    \ until address balance is more or equal than FundMoney.\n\
    \\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\ACK\DC2\ETX\"\EOT$\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\SOH\DC2\ETX\"%3\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\SOH\ETX\DC2\ETX\"67\n\
    \\f\n\
    \\EOT\EOT\SOH\ETX\SOH\DC2\EOT%\STX7\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\SOH\SOH\DC2\ETX%\n\
    \\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\NUL\DC2\ETX&\EOT=\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\EOT\DC2\ETX&\EOT\f\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ACK\DC2\ETX&\r0\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\SOH\DC2\ETX&18\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ETX\DC2\ETX&;<\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\SOH\DC2\ETX'\EOT'\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\EOT\DC2\ETX'\EOT\f\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ACK\DC2\ETX'\r\EM\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\SOH\DC2\ETX'\SUB\"\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ETX\DC2\ETX'%&\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\STX\DC2\ETX(\EOTA\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\EOT\DC2\ETX(\EOT\f\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\ACK\DC2\ETX(\r3\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\SOH\DC2\ETX(4<\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\STX\ETX\DC2\ETX(?@\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\SOH\EOT\NUL\DC2\EOT*\EOT6\ENQ\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\EOT\NUL\SOH\DC2\ETX*\t\NAK\n\
    \\SI\n\
    \\b\EOT\SOH\ETX\SOH\EOT\NUL\STX\NUL\DC2\ETX+\ACK\DC2\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\NUL\SOH\DC2\ETX+\ACK\r\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\NUL\STX\DC2\ETX+\DLE\DC1\n\
    \\250\SOH\n\
    \\b\EOT\SOH\ETX\SOH\EOT\NUL\STX\SOH\DC2\ETX4\ACK/\SUB\232\SOH\n\
    \ NOTE : Removed together with fund_ln_invoice\n\
    \ field from request as errors associated with\n\
    \ this field.\n\
    \\n\
    \ FUND_LN_INVOICE_HAS_NON_ZERO_AMT = 0;\n\
    \ FUND_LN_INVOICE_EXPIRES_TOO_SOON = 1;\n\
    \ FUND_LN_INVOICE_SIGNATURE_IS_NOT_GENUINE = 2;\n\
    \\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\SOH\SOH\DC2\ETX4\ACK*\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\SOH\STX\DC2\ETX4-.\n\
    \\SI\n\
    \\b\EOT\SOH\ETX\SOH\EOT\NUL\STX\STX\DC2\ETX5\ACK0\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\STX\SOH\DC2\ETX5\ACK+\n\
    \\DLE\n\
    \\t\EOT\SOH\ETX\SOH\EOT\NUL\STX\STX\STX\DC2\ETX5./b\ACKproto3"