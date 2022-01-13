{- This file was auto-generated from btc_lsp/method/swap_from_ln.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Method.SwapFromLn (
        Request(), Response(), Response'Either(..), _Response'Success',
        _Response'Failure', Response'Failure(),
        Response'Failure'InternalFailure(), Response'Success()
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
     
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.ctx' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.Ctx@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'ctx' @:: Lens' Request (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.fundAmt' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.FundAmt@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'fundAmt' @:: Lens' Request (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundAmt)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.fundOnChainAddress' @:: Lens' Request Proto.BtcLsp.Data.HighLevel.FundOnChainAddress@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'fundOnChainAddress' @:: Lens' Request (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress)@ -}
data Request
  = Request'_constructor {_Request'ctx :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx),
                          _Request'fundAmt :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundAmt),
                          _Request'fundOnChainAddress :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress),
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
instance Data.ProtoLens.Field.HasField Request "fundAmt" Proto.BtcLsp.Data.HighLevel.FundAmt where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'fundAmt (\ x__ y__ -> x__ {_Request'fundAmt = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'fundAmt" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundAmt) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'fundAmt (\ x__ y__ -> x__ {_Request'fundAmt = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Request "fundOnChainAddress" Proto.BtcLsp.Data.HighLevel.FundOnChainAddress where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'fundOnChainAddress
           (\ x__ y__ -> x__ {_Request'fundOnChainAddress = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Request "maybe'fundOnChainAddress" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundOnChainAddress) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Request'fundOnChainAddress
           (\ x__ y__ -> x__ {_Request'fundOnChainAddress = y__}))
        Prelude.id
instance Data.ProtoLens.Message Request where
  messageName _ = Data.Text.pack "BtcLsp.Method.SwapFromLn.Request"
  packedMessageDescriptor _
    = "\n\
      \\aRequest\DC2,\n\
      \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC29\n\
      \\bfund_amt\CAN\STX \SOH(\v2\RS.BtcLsp.Data.HighLevel.FundAmtR\afundAmt\DC2\\\n\
      \\NAKfund_on_chain_address\CAN\ETX \SOH(\v2).BtcLsp.Data.HighLevel.FundOnChainAddressR\DC2fundOnChainAddress"
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
        fundAmt__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "fund_amt"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.FundAmt)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fundAmt")) ::
              Data.ProtoLens.FieldDescriptor Request
        fundOnChainAddress__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "fund_on_chain_address"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.FundOnChainAddress)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fundOnChainAddress")) ::
              Data.ProtoLens.FieldDescriptor Request
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, ctx__field_descriptor),
           (Data.ProtoLens.Tag 2, fundAmt__field_descriptor),
           (Data.ProtoLens.Tag 3, fundOnChainAddress__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Request'_unknownFields
        (\ x__ y__ -> x__ {_Request'_unknownFields = y__})
  defMessage
    = Request'_constructor
        {_Request'ctx = Prelude.Nothing,
         _Request'fundAmt = Prelude.Nothing,
         _Request'fundOnChainAddress = Prelude.Nothing,
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
                                       "fund_amt"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"fundAmt") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "fund_on_chain_address"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"fundOnChainAddress") y x)
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
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'fundAmt") _x
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
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view
                          (Data.ProtoLens.Field.field @"maybe'fundOnChainAddress") _x
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
                                Data.ProtoLens.encodeMessage
                                _v))
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
                   (_Request'fundAmt x__)
                   (Control.DeepSeq.deepseq (_Request'fundOnChainAddress x__) ())))
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.ctx' @:: Lens' Response Proto.BtcLsp.Data.HighLevel.Ctx@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'ctx' @:: Lens' Response (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.Ctx)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'either' @:: Lens' Response (Prelude.Maybe Response'Either)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'success' @:: Lens' Response (Prelude.Maybe Response'Success)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.success' @:: Lens' Response Response'Success@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'failure' @:: Lens' Response (Prelude.Maybe Response'Failure)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.failure' @:: Lens' Response Response'Failure@ -}
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
  messageName _ = Data.Text.pack "BtcLsp.Method.SwapFromLn.Response"
  packedMessageDescriptor _
    = "\n\
      \\bResponse\DC2,\n\
      \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2F\n\
      \\asuccess\CAN\STX \SOH(\v2*.BtcLsp.Method.SwapFromLn.Response.SuccessH\NULR\asuccess\DC2F\n\
      \\afailure\CAN\ETX \SOH(\v2*.BtcLsp.Method.SwapFromLn.Response.FailureH\NULR\afailure\SUBd\n\
      \\aSuccess\DC2Y\n\
      \\DC4fund_ln_hodl_invoice\CAN\SOH \SOH(\v2(.BtcLsp.Data.HighLevel.FundLnHodlInvoiceR\DC1fundLnHodlInvoice\SUB\175\SOH\n\
      \\aFailure\DC29\n\
      \\ENQinput\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ENQinput\DC2V\n\
      \\binternal\CAN\STX \ETX(\v2:.BtcLsp.Method.SwapFromLn.Response.Failure.InternalFailureR\binternal\SUB\DC1\n\
      \\SIInternalFailureB\b\n\
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
                   (Prelude.Just (Response'Failure' v))
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
     
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.input' @:: Lens' Response'Failure [Proto.BtcLsp.Data.HighLevel.InputFailure]@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.vec'input' @:: Lens' Response'Failure (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure)@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.internal' @:: Lens' Response'Failure [Response'Failure'InternalFailure]@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.vec'internal' @:: Lens' Response'Failure (Data.Vector.Vector Response'Failure'InternalFailure)@ -}
data Response'Failure
  = Response'Failure'_constructor {_Response'Failure'input :: !(Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure),
                                   _Response'Failure'internal :: !(Data.Vector.Vector Response'Failure'InternalFailure),
                                   _Response'Failure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Failure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Failure
instance Data.ProtoLens.Field.HasField Response'Failure "input" [Proto.BtcLsp.Data.HighLevel.InputFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'input
           (\ x__ y__ -> x__ {_Response'Failure'input = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Response'Failure "vec'input" (Data.Vector.Vector Proto.BtcLsp.Data.HighLevel.InputFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'input
           (\ x__ y__ -> x__ {_Response'Failure'input = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField Response'Failure "internal" [Response'Failure'InternalFailure] where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'internal
           (\ x__ y__ -> x__ {_Response'Failure'internal = y__}))
        (Lens.Family2.Unchecked.lens
           Data.Vector.Generic.toList
           (\ _ y__ -> Data.Vector.Generic.fromList y__))
instance Data.ProtoLens.Field.HasField Response'Failure "vec'internal" (Data.Vector.Vector Response'Failure'InternalFailure) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Failure'internal
           (\ x__ y__ -> x__ {_Response'Failure'internal = y__}))
        Prelude.id
instance Data.ProtoLens.Message Response'Failure where
  messageName _
    = Data.Text.pack "BtcLsp.Method.SwapFromLn.Response.Failure"
  packedMessageDescriptor _
    = "\n\
      \\aFailure\DC29\n\
      \\ENQinput\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ENQinput\DC2V\n\
      \\binternal\CAN\STX \ETX(\v2:.BtcLsp.Method.SwapFromLn.Response.Failure.InternalFailureR\binternal\SUB\DC1\n\
      \\SIInternalFailure"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        input__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "input"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.InputFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked (Data.ProtoLens.Field.field @"input")) ::
              Data.ProtoLens.FieldDescriptor Response'Failure
        internal__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "internal"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Response'Failure'InternalFailure)
              (Data.ProtoLens.RepeatedField
                 Data.ProtoLens.Unpacked
                 (Data.ProtoLens.Field.field @"internal")) ::
              Data.ProtoLens.FieldDescriptor Response'Failure
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, input__field_descriptor),
           (Data.ProtoLens.Tag 2, internal__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Failure'_unknownFields
        (\ x__ y__ -> x__ {_Response'Failure'_unknownFields = y__})
  defMessage
    = Response'Failure'_constructor
        {_Response'Failure'input = Data.Vector.Generic.empty,
         _Response'Failure'internal = Data.Vector.Generic.empty,
         _Response'Failure'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Response'Failure
          -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Proto.BtcLsp.Data.HighLevel.InputFailure
             -> Data.ProtoLens.Encoding.Growing.Growing Data.Vector.Vector Data.ProtoLens.Encoding.Growing.RealWorld Response'Failure'InternalFailure
                -> Data.ProtoLens.Encoding.Bytes.Parser Response'Failure
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
instance Control.DeepSeq.NFData Response'Failure where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'Failure'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_Response'Failure'input x__)
                (Control.DeepSeq.deepseq (_Response'Failure'internal x__) ()))
{- | Fields :
      -}
data Response'Failure'InternalFailure
  = Response'Failure'InternalFailure'_constructor {_Response'Failure'InternalFailure'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Failure'InternalFailure where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Failure'InternalFailure
instance Data.ProtoLens.Message Response'Failure'InternalFailure where
  messageName _
    = Data.Text.pack
        "BtcLsp.Method.SwapFromLn.Response.Failure.InternalFailure"
  packedMessageDescriptor _
    = "\n\
      \\SIInternalFailure"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag = let in Data.Map.fromList []
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Failure'InternalFailure'_unknownFields
        (\ x__ y__
           -> x__ {_Response'Failure'InternalFailure'_unknownFields = y__})
  defMessage
    = Response'Failure'InternalFailure'_constructor
        {_Response'Failure'InternalFailure'_unknownFields = []}
  parseMessage
    = let
        loop ::
          Response'Failure'InternalFailure
          -> Data.ProtoLens.Encoding.Bytes.Parser Response'Failure'InternalFailure
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
                      case tag of {
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x) }
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "InternalFailure"
  buildMessage
    = \ _x
        -> Data.ProtoLens.Encoding.Wire.buildFieldSet
             (Lens.Family2.view Data.ProtoLens.unknownFields _x)
instance Control.DeepSeq.NFData Response'Failure'InternalFailure where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Response'Failure'InternalFailure'_unknownFields x__) ()
{- | Fields :
     
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.fundLnHodlInvoice' @:: Lens' Response'Success Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice@
         * 'Proto.BtcLsp.Method.SwapFromLn_Fields.maybe'fundLnHodlInvoice' @:: Lens' Response'Success (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice)@ -}
data Response'Success
  = Response'Success'_constructor {_Response'Success'fundLnHodlInvoice :: !(Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice),
                                   _Response'Success'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Response'Success where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Response'Success
instance Data.ProtoLens.Field.HasField Response'Success "fundLnHodlInvoice" Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'fundLnHodlInvoice
           (\ x__ y__ -> x__ {_Response'Success'fundLnHodlInvoice = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField Response'Success "maybe'fundLnHodlInvoice" (Prelude.Maybe Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Response'Success'fundLnHodlInvoice
           (\ x__ y__ -> x__ {_Response'Success'fundLnHodlInvoice = y__}))
        Prelude.id
instance Data.ProtoLens.Message Response'Success where
  messageName _
    = Data.Text.pack "BtcLsp.Method.SwapFromLn.Response.Success"
  packedMessageDescriptor _
    = "\n\
      \\aSuccess\DC2Y\n\
      \\DC4fund_ln_hodl_invoice\CAN\SOH \SOH(\v2(.BtcLsp.Data.HighLevel.FundLnHodlInvoiceR\DC1fundLnHodlInvoice"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        fundLnHodlInvoice__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "fund_ln_hodl_invoice"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Proto.BtcLsp.Data.HighLevel.FundLnHodlInvoice)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'fundLnHodlInvoice")) ::
              Data.ProtoLens.FieldDescriptor Response'Success
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, fundLnHodlInvoice__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Response'Success'_unknownFields
        (\ x__ y__ -> x__ {_Response'Success'_unknownFields = y__})
  defMessage
    = Response'Success'_constructor
        {_Response'Success'fundLnHodlInvoice = Prelude.Nothing,
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
                                       "fund_ln_hodl_invoice"
                                loop
                                  (Lens.Family2.set
                                     (Data.ProtoLens.Field.field @"fundLnHodlInvoice") y x)
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
                    (Data.ProtoLens.Field.field @"maybe'fundLnHodlInvoice") _x
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
             (Control.DeepSeq.deepseq
                (_Response'Success'fundLnHodlInvoice x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \!btc_lsp/method/swap_from_ln.proto\DC2\CANBtcLsp.Method.SwapFromLn\SUB\GSbtc_lsp/data/high_level.proto\"\208\SOH\n\
    \\aRequest\DC2,\n\
    \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC29\n\
    \\bfund_amt\CAN\STX \SOH(\v2\RS.BtcLsp.Data.HighLevel.FundAmtR\afundAmt\DC2\\\n\
    \\NAKfund_on_chain_address\CAN\ETX \SOH(\v2).BtcLsp.Data.HighLevel.FundOnChainAddressR\DC2fundOnChainAddress\"\234\ETX\n\
    \\bResponse\DC2,\n\
    \\ETXctx\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.HighLevel.CtxR\ETXctx\DC2F\n\
    \\asuccess\CAN\STX \SOH(\v2*.BtcLsp.Method.SwapFromLn.Response.SuccessH\NULR\asuccess\DC2F\n\
    \\afailure\CAN\ETX \SOH(\v2*.BtcLsp.Method.SwapFromLn.Response.FailureH\NULR\afailure\SUBd\n\
    \\aSuccess\DC2Y\n\
    \\DC4fund_ln_hodl_invoice\CAN\SOH \SOH(\v2(.BtcLsp.Data.HighLevel.FundLnHodlInvoiceR\DC1fundLnHodlInvoice\SUB\175\SOH\n\
    \\aFailure\DC29\n\
    \\ENQinput\CAN\SOH \ETX(\v2#.BtcLsp.Data.HighLevel.InputFailureR\ENQinput\DC2V\n\
    \\binternal\CAN\STX \ETX(\v2:.BtcLsp.Method.SwapFromLn.Response.Failure.InternalFailureR\binternal\SUB\DC1\n\
    \\SIInternalFailureB\b\n\
    \\ACKeitherJ\242\ENQ\n\
    \\ACK\DC2\EOT\NUL\NUL \SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\STX\NUL!\n\
    \\t\n\
    \\STX\ETX\NUL\DC2\ETX\EOT\NUL'\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\ACK\NUL\n\
    \\SOH\n\
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
    \\v\n\
    \\EOT\EOT\NUL\STX\SOH\DC2\ETX\b\STX.\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ACK\DC2\ETX\b\STX \n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\SOH\DC2\ETX\b!)\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\SOH\ETX\DC2\ETX\b,-\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\STX\DC2\ETX\t\STXF\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ACK\DC2\ETX\t\STX+\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\SOH\DC2\ETX\t,A\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\STX\ETX\DC2\ETX\tDE\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\f\NUL \SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\f\b\DLE\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\r\STX%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\r\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\r\GS \n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\r#$\n\
    \\f\n\
    \\EOT\EOT\SOH\b\NUL\DC2\EOT\SI\STX\DC2\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\b\NUL\SOH\DC2\ETX\SI\b\SO\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\SOH\DC2\ETX\DLE\EOT\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ACK\DC2\ETX\DLE\EOT\v\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\SOH\DC2\ETX\DLE\f\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\SOH\ETX\DC2\ETX\DLE\SYN\ETB\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\STX\DC2\ETX\DC1\EOT\CAN\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ACK\DC2\ETX\DC1\EOT\v\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\SOH\DC2\ETX\DC1\f\DC3\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\STX\ETX\DC2\ETX\DC1\SYN\ETB\n\
    \\f\n\
    \\EOT\EOT\SOH\ETX\NUL\DC2\EOT\DC4\STX\SYN\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\NUL\SOH\DC2\ETX\DC4\n\
    \\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\NUL\STX\NUL\DC2\ETX\NAK\EOTF\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ACK\DC2\ETX\NAK\EOT,\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\SOH\DC2\ETX\NAK-A\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\NUL\STX\NUL\ETX\DC2\ETX\NAKDE\n\
    \\f\n\
    \\EOT\EOT\SOH\ETX\SOH\DC2\EOT\CAN\STX\US\ETX\n\
    \\f\n\
    \\ENQ\EOT\SOH\ETX\SOH\SOH\DC2\ETX\CAN\n\
    \\DC1\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\NUL\DC2\ETX\EM\EOT;\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\EOT\DC2\ETX\EM\EOT\f\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ACK\DC2\ETX\EM\r0\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\SOH\DC2\ETX\EM16\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\NUL\ETX\DC2\ETX\EM9:\n\
    \\r\n\
    \\ACK\EOT\SOH\ETX\SOH\STX\SOH\DC2\ETX\SUB\EOT*\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\EOT\DC2\ETX\SUB\EOT\f\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ACK\DC2\ETX\SUB\r\FS\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\SOH\DC2\ETX\SUB\GS%\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\STX\SOH\ETX\DC2\ETX\SUB()\n\
    \\SO\n\
    \\ACK\EOT\SOH\ETX\SOH\ETX\NUL\DC2\EOT\FS\EOT\RS\ENQ\n\
    \\SO\n\
    \\a\EOT\SOH\ETX\SOH\ETX\NUL\SOH\DC2\ETX\FS\f\ESCb\ACKproto3"