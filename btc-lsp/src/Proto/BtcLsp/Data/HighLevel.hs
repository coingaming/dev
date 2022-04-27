{- This file was auto-generated from btc_lsp/data/high_level.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Data.HighLevel (
        Ctx(), FeeMoney(), FeeRate(), FieldIndex(), FundLnHodlInvoice(),
        FundLnInvoice(), FundMoney(), FundOnChainAddress(), InputFailure(),
        InputFailureKind(..), InputFailureKind(),
        InputFailureKind'UnrecognizedValue, LnHost(), LnPeer(), LnPort(),
        LnPubKey(), LocalBalance(), Nonce(), RefundMoney(),
        RefundOnChainAddress(), RemoteBalance()
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
                          Data.ProtoLens.encodeMessage _v))
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
                             Data.ProtoLens.encodeMessage _v))
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
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FeeMoney Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FeeMoney (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data FeeMoney
  = FeeMoney'_constructor {_FeeMoney'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                           _FeeMoney'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FeeMoney where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FeeMoney
instance Data.ProtoLens.Field.HasField FeeMoney "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeMoney'val (\ x__ y__ -> x__ {_FeeMoney'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FeeMoney "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FeeMoney'val (\ x__ y__ -> x__ {_FeeMoney'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FeeMoney where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FeeMoney"
  packedMessageDescriptor _
    = "\n\
      \\bFeeMoney\DC2,\n\
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
              Data.ProtoLens.FieldDescriptor FeeMoney
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FeeMoney'_unknownFields
        (\ x__ y__ -> x__ {_FeeMoney'_unknownFields = y__})
  defMessage
    = FeeMoney'_constructor
        {_FeeMoney'val = Prelude.Nothing, _FeeMoney'_unknownFields = []}
  parseMessage
    = let
        loop :: FeeMoney -> Data.ProtoLens.Encoding.Bytes.Parser FeeMoney
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
          (do loop Data.ProtoLens.defMessage) "FeeMoney"
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
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FeeMoney where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FeeMoney'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FeeMoney'val x__) ())
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
                          Data.ProtoLens.encodeMessage _v))
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
                          Data.ProtoLens.encodeMessage _v))
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
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundLnInvoice where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundLnInvoice'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundLnInvoice'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' FundMoney Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' FundMoney (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data FundMoney
  = FundMoney'_constructor {_FundMoney'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                            _FundMoney'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show FundMoney where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out FundMoney
instance Data.ProtoLens.Field.HasField FundMoney "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundMoney'val (\ x__ y__ -> x__ {_FundMoney'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField FundMoney "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _FundMoney'val (\ x__ y__ -> x__ {_FundMoney'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message FundMoney where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.FundMoney"
  packedMessageDescriptor _
    = "\n\
      \\tFundMoney\DC2,\n\
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
              Data.ProtoLens.FieldDescriptor FundMoney
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _FundMoney'_unknownFields
        (\ x__ y__ -> x__ {_FundMoney'_unknownFields = y__})
  defMessage
    = FundMoney'_constructor
        {_FundMoney'val = Prelude.Nothing, _FundMoney'_unknownFields = []}
  parseMessage
    = let
        loop :: FundMoney -> Data.ProtoLens.Encoding.Bytes.Parser FundMoney
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
          (do loop Data.ProtoLens.defMessage) "FundMoney"
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
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData FundMoney where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_FundMoney'_unknownFields x__)
             (Control.DeepSeq.deepseq (_FundMoney'val x__) ())
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
                          Data.ProtoLens.encodeMessage _v))
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
                           Data.ProtoLens.unknownFields (\ !t -> Prelude.reverse t)
                           (Lens.Family2.set
                              (Data.ProtoLens.Field.field @"vec'fieldLocation")
                              frozen'fieldLocation x))
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
                           Data.ProtoLens.encodeMessage _v))
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
                            Prelude.fromEnum _v))
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
        Prelude.id (Data.ProtoLens.maybeToEnum k__)
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
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' LnHost Data.Text.Text@ -}
data LnHost
  = LnHost'_constructor {_LnHost'val :: !Data.Text.Text,
                         _LnHost'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnHost where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnHost
instance Data.ProtoLens.Field.HasField LnHost "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnHost'val (\ x__ y__ -> x__ {_LnHost'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnHost where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.LnHost"
  packedMessageDescriptor _
    = "\n\
      \\ACKLnHost\DC2\DLE\n\
      \\ETXval\CAN\SOH \SOH(\tR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.ScalarField Data.ProtoLens.StringField ::
                 Data.ProtoLens.FieldTypeDescriptor Data.Text.Text)
              (Data.ProtoLens.PlainField
                 Data.ProtoLens.Optional (Data.ProtoLens.Field.field @"val")) ::
              Data.ProtoLens.FieldDescriptor LnHost
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnHost'_unknownFields
        (\ x__ y__ -> x__ {_LnHost'_unknownFields = y__})
  defMessage
    = LnHost'_constructor
        {_LnHost'val = Data.ProtoLens.fieldDefault,
         _LnHost'_unknownFields = []}
  parseMessage
    = let
        loop :: LnHost -> Data.ProtoLens.Encoding.Bytes.Parser LnHost
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
                                       (do value <- do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                                       Data.ProtoLens.Encoding.Bytes.getBytes
                                                         (Prelude.fromIntegral len)
                                           Data.ProtoLens.Encoding.Bytes.runEither
                                             (case Data.Text.Encoding.decodeUtf8' value of
                                                (Prelude.Left err)
                                                  -> Prelude.Left (Prelude.show err)
                                                (Prelude.Right r) -> Prelude.Right r))
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
          (do loop Data.ProtoLens.defMessage) "LnHost"
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
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8 _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LnHost where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnHost'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LnHost'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.pubKey' @:: Lens' LnPeer LnPubKey@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'pubKey' @:: Lens' LnPeer (Prelude.Maybe LnPubKey)@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.host' @:: Lens' LnPeer LnHost@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'host' @:: Lens' LnPeer (Prelude.Maybe LnHost)@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.port' @:: Lens' LnPeer LnPort@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'port' @:: Lens' LnPeer (Prelude.Maybe LnPort)@ -}
data LnPeer
  = LnPeer'_constructor {_LnPeer'pubKey :: !(Prelude.Maybe LnPubKey),
                         _LnPeer'host :: !(Prelude.Maybe LnHost),
                         _LnPeer'port :: !(Prelude.Maybe LnPort),
                         _LnPeer'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnPeer where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnPeer
instance Data.ProtoLens.Field.HasField LnPeer "pubKey" LnPubKey where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'pubKey (\ x__ y__ -> x__ {_LnPeer'pubKey = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LnPeer "maybe'pubKey" (Prelude.Maybe LnPubKey) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'pubKey (\ x__ y__ -> x__ {_LnPeer'pubKey = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField LnPeer "host" LnHost where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'host (\ x__ y__ -> x__ {_LnPeer'host = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LnPeer "maybe'host" (Prelude.Maybe LnHost) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'host (\ x__ y__ -> x__ {_LnPeer'host = y__}))
        Prelude.id
instance Data.ProtoLens.Field.HasField LnPeer "port" LnPort where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'port (\ x__ y__ -> x__ {_LnPeer'port = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LnPeer "maybe'port" (Prelude.Maybe LnPort) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPeer'port (\ x__ y__ -> x__ {_LnPeer'port = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnPeer where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.LnPeer"
  packedMessageDescriptor _
    = "\n\
      \\ACKLnPeer\DC28\n\
      \\apub_key\CAN\SOH \SOH(\v2\US.BtcLsp.Data.HighLevel.LnPubKeyR\ACKpubKey\DC21\n\
      \\EOThost\CAN\STX \SOH(\v2\GS.BtcLsp.Data.HighLevel.LnHostR\EOThost\DC21\n\
      \\EOTport\CAN\ETX \SOH(\v2\GS.BtcLsp.Data.HighLevel.LnPortR\EOTport"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        pubKey__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "pub_key"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor LnPubKey)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'pubKey")) ::
              Data.ProtoLens.FieldDescriptor LnPeer
        host__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "host"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor LnHost)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'host")) ::
              Data.ProtoLens.FieldDescriptor LnPeer
        port__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "port"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor LnPort)
              (Data.ProtoLens.OptionalField
                 (Data.ProtoLens.Field.field @"maybe'port")) ::
              Data.ProtoLens.FieldDescriptor LnPeer
      in
        Data.Map.fromList
          [(Data.ProtoLens.Tag 1, pubKey__field_descriptor),
           (Data.ProtoLens.Tag 2, host__field_descriptor),
           (Data.ProtoLens.Tag 3, port__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnPeer'_unknownFields
        (\ x__ y__ -> x__ {_LnPeer'_unknownFields = y__})
  defMessage
    = LnPeer'_constructor
        {_LnPeer'pubKey = Prelude.Nothing, _LnPeer'host = Prelude.Nothing,
         _LnPeer'port = Prelude.Nothing, _LnPeer'_unknownFields = []}
  parseMessage
    = let
        loop :: LnPeer -> Data.ProtoLens.Encoding.Bytes.Parser LnPeer
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
                                       "pub_key"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"pubKey") y x)
                        18
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "host"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"host") y x)
                        26
                          -> do y <- (Data.ProtoLens.Encoding.Bytes.<?>)
                                       (do len <- Data.ProtoLens.Encoding.Bytes.getVarInt
                                           Data.ProtoLens.Encoding.Bytes.isolate
                                             (Prelude.fromIntegral len) Data.ProtoLens.parseMessage)
                                       "port"
                                loop (Lens.Family2.set (Data.ProtoLens.Field.field @"port") y x)
                        wire
                          -> do !y <- Data.ProtoLens.Encoding.Wire.parseTaggedValueFromWire
                                        wire
                                loop
                                  (Lens.Family2.over
                                     Data.ProtoLens.unknownFields (\ !t -> (:) y t) x)
      in
        (Data.ProtoLens.Encoding.Bytes.<?>)
          (do loop Data.ProtoLens.defMessage) "LnPeer"
  buildMessage
    = \ _x
        -> (Data.Monoid.<>)
             (case
                  Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'pubKey") _x
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
                     Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'host") _x
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
                ((Data.Monoid.<>)
                   (case
                        Lens.Family2.view (Data.ProtoLens.Field.field @"maybe'port") _x
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
                   (Data.ProtoLens.Encoding.Wire.buildFieldSet
                      (Lens.Family2.view Data.ProtoLens.unknownFields _x))))
instance Control.DeepSeq.NFData LnPeer where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnPeer'_unknownFields x__)
             (Control.DeepSeq.deepseq
                (_LnPeer'pubKey x__)
                (Control.DeepSeq.deepseq
                   (_LnPeer'host x__)
                   (Control.DeepSeq.deepseq (_LnPeer'port x__) ())))
{- | Fields :
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' LnPort Data.Word.Word32@ -}
data LnPort
  = LnPort'_constructor {_LnPort'val :: !Data.Word.Word32,
                         _LnPort'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnPort where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnPort
instance Data.ProtoLens.Field.HasField LnPort "val" Data.Word.Word32 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPort'val (\ x__ y__ -> x__ {_LnPort'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnPort where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.LnPort"
  packedMessageDescriptor _
    = "\n\
      \\ACKLnPort\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor LnPort
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnPort'_unknownFields
        (\ x__ y__ -> x__ {_LnPort'_unknownFields = y__})
  defMessage
    = LnPort'_constructor
        {_LnPort'val = Data.ProtoLens.fieldDefault,
         _LnPort'_unknownFields = []}
  parseMessage
    = let
        loop :: LnPort -> Data.ProtoLens.Encoding.Bytes.Parser LnPort
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
          (do loop Data.ProtoLens.defMessage) "LnPort"
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
instance Control.DeepSeq.NFData LnPort where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnPort'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LnPort'val x__) ())
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
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LocalBalance where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LocalBalance'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LocalBalance'val x__) ())
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
     
         * 'Proto.BtcLsp.Data.HighLevel_Fields.val' @:: Lens' RefundMoney Proto.BtcLsp.Data.LowLevel.Msat@
         * 'Proto.BtcLsp.Data.HighLevel_Fields.maybe'val' @:: Lens' RefundMoney (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat)@ -}
data RefundMoney
  = RefundMoney'_constructor {_RefundMoney'val :: !(Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat),
                              _RefundMoney'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show RefundMoney where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out RefundMoney
instance Data.ProtoLens.Field.HasField RefundMoney "val" Proto.BtcLsp.Data.LowLevel.Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundMoney'val (\ x__ y__ -> x__ {_RefundMoney'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RefundMoney "maybe'val" (Prelude.Maybe Proto.BtcLsp.Data.LowLevel.Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RefundMoney'val (\ x__ y__ -> x__ {_RefundMoney'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message RefundMoney where
  messageName _ = Data.Text.pack "BtcLsp.Data.HighLevel.RefundMoney"
  packedMessageDescriptor _
    = "\n\
      \\vRefundMoney\DC2,\n\
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
              Data.ProtoLens.FieldDescriptor RefundMoney
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _RefundMoney'_unknownFields
        (\ x__ y__ -> x__ {_RefundMoney'_unknownFields = y__})
  defMessage
    = RefundMoney'_constructor
        {_RefundMoney'val = Prelude.Nothing,
         _RefundMoney'_unknownFields = []}
  parseMessage
    = let
        loop ::
          RefundMoney -> Data.ProtoLens.Encoding.Bytes.Parser RefundMoney
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
          (do loop Data.ProtoLens.defMessage) "RefundMoney"
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
                          Data.ProtoLens.encodeMessage _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData RefundMoney where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_RefundMoney'_unknownFields x__)
             (Control.DeepSeq.deepseq (_RefundMoney'val x__) ())
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
                          Data.ProtoLens.encodeMessage _v))
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
                          Data.ProtoLens.encodeMessage _v))
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
    \\GSbtc_lsp/data/high_level.proto\DC2\NAKBtcLsp.Data.HighLevel\SUB\FSbtc_lsp/data/low_level.proto\"<\n\
    \\aFeeRate\DC21\n\
    \\ETXval\CAN\SOH \SOH(\v2\US.BtcLsp.Data.LowLevel.UrationalR\ETXval\"8\n\
    \\bFeeMoney\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\"9\n\
    \\tFundMoney\DC2,\n\
    \\ETXval\CAN\SOH \SOH(\v2\SUB.BtcLsp.Data.LowLevel.MsatR\ETXval\";\n\
    \\vRefundMoney\DC2,\n\
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
    \\ETXval\CAN\SOH \SOH(\fR\ETXval\"\SUB\n\
    \\ACKLnHost\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXval\"\SUB\n\
    \\ACKLnPort\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\rR\ETXval\"\168\SOH\n\
    \\ACKLnPeer\DC28\n\
    \\apub_key\CAN\SOH \SOH(\v2\US.BtcLsp.Data.HighLevel.LnPubKeyR\ACKpubKey\DC21\n\
    \\EOThost\CAN\STX \SOH(\v2\GS.BtcLsp.Data.HighLevel.LnHostR\EOThost\DC21\n\
    \\EOTport\CAN\ETX \SOH(\v2\GS.BtcLsp.Data.HighLevel.LnPortR\EOTport\"\149\SOH\n\
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
    \\DC3VERIFICATION_FAILED\DLE\ETXJ\226\SYN\n\
    \\ACK\DC2\EOT\NUL\NULr\SOH\n\
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
    \\ETX\EOT\NUL\SOH\DC2\ETX\v\b\SI\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\f\STX*\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ACK\DC2\ETX\f\STX!\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\f\"%\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\f()\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\SI\NUL\DC1\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\SI\b\DLE\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\DLE\STX%\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ACK\DC2\ETX\DLE\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\DLE\GS \n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\DLE#$\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\DC3\NUL\NAK\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\DC3\b\DC1\n\
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
    \\ETX\EOT\ETX\SOH\DC2\ETX\ETB\b\DC3\n\
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
    \\ETX\EOT\EOT\SOH\DC2\ETX\ESC\b\DC4\n\
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
    \\ETX\EOT\ENQ\SOH\DC2\ETX\US\b\NAK\n\
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
    \\EOT\EOT\ACK\STX\NUL\DC2\ETX$\STX*\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ACK\DC2\ETX$\STX!\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\ETX$\"%\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\ETX$()\n\
    \\n\
    \\n\
    \\STX\EOT\a\DC2\EOT'\NUL)\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\a\SOH\DC2\ETX'\b\EM\n\
    \\v\n\
    \\EOT\EOT\a\STX\NUL\DC2\ETX(\STX.\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ACK\DC2\ETX(\STX%\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\ETX(&)\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\ETX(,-\n\
    \\n\
    \\n\
    \\STX\EOT\b\DC2\EOT+\NUL-\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\b\SOH\DC2\ETX+\b\SUB\n\
    \\v\n\
    \\EOT\EOT\b\STX\NUL\DC2\ETX,\STX/\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ACK\DC2\ETX,\STX&\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\ETX,'*\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\ETX,-.\n\
    \\n\
    \\n\
    \\STX\EOT\t\DC2\EOT/\NUL1\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\t\SOH\DC2\ETX/\b\FS\n\
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
    \\DC2\EOT3\NUL6\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\n\
    \\SOH\DC2\ETX3\b\v\n\
    \\v\n\
    \\EOT\EOT\n\
    \\STX\NUL\DC2\ETX4\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ACK\DC2\ETX4\STX\a\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\SOH\DC2\ETX4\b\r\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\NUL\ETX\DC2\ETX4\DLE\DC1\n\
    \\v\n\
    \\EOT\EOT\n\
    \\STX\SOH\DC2\ETX5\STX\SUB\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ACK\DC2\ETX5\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\SOH\SOH\DC2\ETX5\v\NAK\n\
    \\f\n\
    \\ENQ\EOT\n\
    \\STX\SOH\ETX\DC2\ETX5\CAN\EM\n\
    \\233\STX\n\
    \\STX\EOT\v\DC2\EOTB\NULD\SOH2\220\STX\n\
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
    \\ETX\EOT\v\SOH\DC2\ETXB\b\r\n\
    \\v\n\
    \\EOT\EOT\v\STX\NUL\DC2\ETXC\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ENQ\DC2\ETXC\STX\b\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\SOH\DC2\ETXC\t\f\n\
    \\f\n\
    \\ENQ\EOT\v\STX\NUL\ETX\DC2\ETXC\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\f\DC2\EOTF\NULH\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\f\SOH\DC2\ETXF\b\DLE\n\
    \\v\n\
    \\EOT\EOT\f\STX\NUL\DC2\ETXG\STX\DLE\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ENQ\DC2\ETXG\STX\a\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\SOH\DC2\ETXG\b\v\n\
    \\f\n\
    \\ENQ\EOT\f\STX\NUL\ETX\DC2\ETXG\SO\SI\n\
    \\n\
    \\n\
    \\STX\EOT\r\DC2\EOTJ\NULL\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\r\SOH\DC2\ETXJ\b\SO\n\
    \\v\n\
    \\EOT\EOT\r\STX\NUL\DC2\ETXK\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\ENQ\DC2\ETXK\STX\b\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\SOH\DC2\ETXK\t\f\n\
    \\f\n\
    \\ENQ\EOT\r\STX\NUL\ETX\DC2\ETXK\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\SO\DC2\EOTN\NULP\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SO\SOH\DC2\ETXN\b\SO\n\
    \\v\n\
    \\EOT\EOT\SO\STX\NUL\DC2\ETXO\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\ENQ\DC2\ETXO\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\SOH\DC2\ETXO\t\f\n\
    \\f\n\
    \\ENQ\EOT\SO\STX\NUL\ETX\DC2\ETXO\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\SI\DC2\EOTR\NULV\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SI\SOH\DC2\ETXR\b\SO\n\
    \\v\n\
    \\EOT\EOT\SI\STX\NUL\DC2\ETXS\STX\ETB\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\ACK\DC2\ETXS\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\SOH\DC2\ETXS\v\DC2\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\NUL\ETX\DC2\ETXS\NAK\SYN\n\
    \\v\n\
    \\EOT\EOT\SI\STX\SOH\DC2\ETXT\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\SOH\ACK\DC2\ETXT\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\SOH\SOH\DC2\ETXT\t\r\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\SOH\ETX\DC2\ETXT\DLE\DC1\n\
    \\v\n\
    \\EOT\EOT\SI\STX\STX\DC2\ETXU\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\STX\ACK\DC2\ETXU\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\STX\SOH\DC2\ETXU\t\r\n\
    \\f\n\
    \\ENQ\EOT\SI\STX\STX\ETX\DC2\ETXU\DLE\DC1\n\
    \\n\
    \\n\
    \\STX\EOT\DLE\DC2\EOTX\NUL[\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\DLE\SOH\DC2\ETXX\b\DC4\n\
    \\v\n\
    \\EOT\EOT\DLE\STX\NUL\DC2\ETXY\STX)\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\NUL\EOT\DC2\ETXY\STX\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\NUL\ACK\DC2\ETXY\v\NAK\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\NUL\SOH\DC2\ETXY\SYN$\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\NUL\ETX\DC2\ETXY'(\n\
    \\v\n\
    \\EOT\EOT\DLE\STX\SOH\DC2\ETXZ\STX\FS\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\SOH\ACK\DC2\ETXZ\STX\DC2\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\SOH\SOH\DC2\ETXZ\DC3\ETB\n\
    \\f\n\
    \\ENQ\EOT\DLE\STX\SOH\ETX\DC2\ETXZ\SUB\ESC\n\
    \\n\
    \\n\
    \\STX\EOT\DC1\DC2\EOT]\NUL_\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\DC1\SOH\DC2\ETX]\b\DC2\n\
    \\v\n\
    \\EOT\EOT\DC1\STX\NUL\DC2\ETX^\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\DC1\STX\NUL\ENQ\DC2\ETX^\STX\b\n\
    \\f\n\
    \\ENQ\EOT\DC1\STX\NUL\SOH\DC2\ETX^\t\f\n\
    \\f\n\
    \\ENQ\EOT\DC1\STX\NUL\ETX\DC2\ETX^\SI\DLE\n\
    \\n\
    \\n\
    \\STX\ENQ\NUL\DC2\EOTa\NULr\SOH\n\
    \\n\
    \\n\
    \\ETX\ENQ\NUL\SOH\DC2\ETXa\ENQ\NAK\n\
    \l\n\
    \\EOT\ENQ\NUL\STX\NUL\DC2\ETXd\STX\SI\SUB_ All proto3 messages are optional, but sometimes\n\
    \ message presence is required by source code.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\SOH\DC2\ETXd\STX\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\NUL\STX\DC2\ETXd\r\SO\n\
    \\182\SOH\n\
    \\EOT\ENQ\NUL\STX\SOH\DC2\ETXh\STX\DLE\SUB\168\SOH Sometimes protobuf term is not data itself, but reference\n\
    \ to some other data, located somewhere else, for example\n\
    \ in database, and this resource might be not found.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\SOH\DC2\ETXh\STX\v\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\SOH\STX\DC2\ETXh\SO\SI\n\
    \\201\SOH\n\
    \\EOT\ENQ\NUL\STX\STX\DC2\ETXm\STX\NAK\SUB\187\SOH Sometimes data is required to be in some\n\
    \ specific format (for example DER binary encoding)\n\
    \ which is not the part of proto3 type system.\n\
    \ This error shows the failure of custom parser.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\SOH\DC2\ETXm\STX\DLE\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\STX\STX\DC2\ETXm\DC3\DC4\n\
    \\157\SOH\n\
    \\EOT\ENQ\NUL\STX\ETX\DC2\ETXq\STX\SUB\SUB\143\SOH Even if custom parser succeeded, sometimes data\n\
    \ needs to be verified somehow, for example\n\
    \ signature needs to be cryptographically verified.\n\
    \\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\SOH\DC2\ETXq\STX\NAK\n\
    \\f\n\
    \\ENQ\ENQ\NUL\STX\ETX\STX\DC2\ETXq\CAN\EMb\ACKproto3"