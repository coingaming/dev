{- This file was auto-generated from btc_lsp/newtype.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp.Newtype (
        FieldIndex(), LnHodlInvoice(), LnInvoice(), LnPubKey(),
        LocalBalance(), Msat(), Nonce(), OnChainAddress(), RemoteBalance(),
        SocketAddress()
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
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' FieldIndex Data.Word.Word32@ -}
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
  messageName _ = Data.Text.pack "BtcLsp.Newtype.FieldIndex"
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
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' LnHodlInvoice Data.Text.Text@ -}
data LnHodlInvoice
  = LnHodlInvoice'_constructor {_LnHodlInvoice'val :: !Data.Text.Text,
                                _LnHodlInvoice'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnHodlInvoice where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnHodlInvoice
instance Data.ProtoLens.Field.HasField LnHodlInvoice "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnHodlInvoice'val (\ x__ y__ -> x__ {_LnHodlInvoice'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnHodlInvoice where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.LnHodlInvoice"
  packedMessageDescriptor _
    = "\n\
      \\rLnHodlInvoice\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor LnHodlInvoice
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnHodlInvoice'_unknownFields
        (\ x__ y__ -> x__ {_LnHodlInvoice'_unknownFields = y__})
  defMessage
    = LnHodlInvoice'_constructor
        {_LnHodlInvoice'val = Data.ProtoLens.fieldDefault,
         _LnHodlInvoice'_unknownFields = []}
  parseMessage
    = let
        loop ::
          LnHodlInvoice -> Data.ProtoLens.Encoding.Bytes.Parser LnHodlInvoice
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
          (do loop Data.ProtoLens.defMessage) "LnHodlInvoice"
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
                         Data.Text.Encoding.encodeUtf8
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LnHodlInvoice where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnHodlInvoice'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LnHodlInvoice'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' LnInvoice Data.Text.Text@ -}
data LnInvoice
  = LnInvoice'_constructor {_LnInvoice'val :: !Data.Text.Text,
                            _LnInvoice'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnInvoice where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnInvoice
instance Data.ProtoLens.Field.HasField LnInvoice "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnInvoice'val (\ x__ y__ -> x__ {_LnInvoice'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnInvoice where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.LnInvoice"
  packedMessageDescriptor _
    = "\n\
      \\tLnInvoice\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor LnInvoice
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _LnInvoice'_unknownFields
        (\ x__ y__ -> x__ {_LnInvoice'_unknownFields = y__})
  defMessage
    = LnInvoice'_constructor
        {_LnInvoice'val = Data.ProtoLens.fieldDefault,
         _LnInvoice'_unknownFields = []}
  parseMessage
    = let
        loop :: LnInvoice -> Data.ProtoLens.Encoding.Bytes.Parser LnInvoice
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
          (do loop Data.ProtoLens.defMessage) "LnInvoice"
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
                         Data.Text.Encoding.encodeUtf8
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData LnInvoice where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_LnInvoice'_unknownFields x__)
             (Control.DeepSeq.deepseq (_LnInvoice'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' LnPubKey Data.Text.Text@ -}
data LnPubKey
  = LnPubKey'_constructor {_LnPubKey'val :: !Data.Text.Text,
                           _LnPubKey'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LnPubKey where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LnPubKey
instance Data.ProtoLens.Field.HasField LnPubKey "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LnPubKey'val (\ x__ y__ -> x__ {_LnPubKey'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LnPubKey where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.LnPubKey"
  packedMessageDescriptor _
    = "\n\
      \\bLnPubKey\DC2\DLE\n\
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
                      ((Prelude..)
                         (\ bs
                            -> (Data.Monoid.<>)
                                 (Data.ProtoLens.Encoding.Bytes.putVarInt
                                    (Prelude.fromIntegral (Data.ByteString.length bs)))
                                 (Data.ProtoLens.Encoding.Bytes.putBytes bs))
                         Data.Text.Encoding.encodeUtf8
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
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' LocalBalance Msat@
         * 'Proto.BtcLsp.Newtype_Fields.maybe'val' @:: Lens' LocalBalance (Prelude.Maybe Msat)@ -}
data LocalBalance
  = LocalBalance'_constructor {_LocalBalance'val :: !(Prelude.Maybe Msat),
                               _LocalBalance'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show LocalBalance where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out LocalBalance
instance Data.ProtoLens.Field.HasField LocalBalance "val" Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LocalBalance'val (\ x__ y__ -> x__ {_LocalBalance'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField LocalBalance "maybe'val" (Prelude.Maybe Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _LocalBalance'val (\ x__ y__ -> x__ {_LocalBalance'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message LocalBalance where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.LocalBalance"
  packedMessageDescriptor _
    = "\n\
      \\fLocalBalance\DC2&\n\
      \\ETXval\CAN\SOH \SOH(\v2\DC4.BtcLsp.Newtype.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Msat)
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
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' Msat Data.Word.Word64@ -}
data Msat
  = Msat'_constructor {_Msat'val :: !Data.Word.Word64,
                       _Msat'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show Msat where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out Msat
instance Data.ProtoLens.Field.HasField Msat "val" Data.Word.Word64 where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _Msat'val (\ x__ y__ -> x__ {_Msat'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message Msat where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.Msat"
  packedMessageDescriptor _
    = "\n\
      \\EOTMsat\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor Msat
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _Msat'_unknownFields
        (\ x__ y__ -> x__ {_Msat'_unknownFields = y__})
  defMessage
    = Msat'_constructor
        {_Msat'val = Data.ProtoLens.fieldDefault,
         _Msat'_unknownFields = []}
  parseMessage
    = let
        loop :: Msat -> Data.ProtoLens.Encoding.Bytes.Parser Msat
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
          (do loop Data.ProtoLens.defMessage) "Msat"
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
instance Control.DeepSeq.NFData Msat where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_Msat'_unknownFields x__)
             (Control.DeepSeq.deepseq (_Msat'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' Nonce Data.Word.Word64@ -}
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
  messageName _ = Data.Text.pack "BtcLsp.Newtype.Nonce"
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
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' OnChainAddress Data.Text.Text@ -}
data OnChainAddress
  = OnChainAddress'_constructor {_OnChainAddress'val :: !Data.Text.Text,
                                 _OnChainAddress'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show OnChainAddress where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out OnChainAddress
instance Data.ProtoLens.Field.HasField OnChainAddress "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _OnChainAddress'val (\ x__ y__ -> x__ {_OnChainAddress'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message OnChainAddress where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.OnChainAddress"
  packedMessageDescriptor _
    = "\n\
      \\SOOnChainAddress\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor OnChainAddress
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _OnChainAddress'_unknownFields
        (\ x__ y__ -> x__ {_OnChainAddress'_unknownFields = y__})
  defMessage
    = OnChainAddress'_constructor
        {_OnChainAddress'val = Data.ProtoLens.fieldDefault,
         _OnChainAddress'_unknownFields = []}
  parseMessage
    = let
        loop ::
          OnChainAddress
          -> Data.ProtoLens.Encoding.Bytes.Parser OnChainAddress
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
          (do loop Data.ProtoLens.defMessage) "OnChainAddress"
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
                         Data.Text.Encoding.encodeUtf8
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData OnChainAddress where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_OnChainAddress'_unknownFields x__)
             (Control.DeepSeq.deepseq (_OnChainAddress'val x__) ())
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' RemoteBalance Msat@
         * 'Proto.BtcLsp.Newtype_Fields.maybe'val' @:: Lens' RemoteBalance (Prelude.Maybe Msat)@ -}
data RemoteBalance
  = RemoteBalance'_constructor {_RemoteBalance'val :: !(Prelude.Maybe Msat),
                                _RemoteBalance'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show RemoteBalance where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out RemoteBalance
instance Data.ProtoLens.Field.HasField RemoteBalance "val" Msat where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RemoteBalance'val (\ x__ y__ -> x__ {_RemoteBalance'val = y__}))
        (Data.ProtoLens.maybeLens Data.ProtoLens.defMessage)
instance Data.ProtoLens.Field.HasField RemoteBalance "maybe'val" (Prelude.Maybe Msat) where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _RemoteBalance'val (\ x__ y__ -> x__ {_RemoteBalance'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message RemoteBalance where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.RemoteBalance"
  packedMessageDescriptor _
    = "\n\
      \\rRemoteBalance\DC2&\n\
      \\ETXval\CAN\SOH \SOH(\v2\DC4.BtcLsp.Newtype.MsatR\ETXval"
  packedFileDescriptor _ = packedFileDescriptor
  fieldsByTag
    = let
        val__field_descriptor
          = Data.ProtoLens.FieldDescriptor
              "val"
              (Data.ProtoLens.MessageField Data.ProtoLens.MessageType ::
                 Data.ProtoLens.FieldTypeDescriptor Msat)
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
{- | Fields :
     
         * 'Proto.BtcLsp.Newtype_Fields.val' @:: Lens' SocketAddress Data.Text.Text@ -}
data SocketAddress
  = SocketAddress'_constructor {_SocketAddress'val :: !Data.Text.Text,
                                _SocketAddress'_unknownFields :: !Data.ProtoLens.FieldSet}
  deriving stock (Prelude.Eq, Prelude.Ord, GHC.Generics.Generic)
instance Prelude.Show SocketAddress where
  showsPrec _ __x __s
    = Prelude.showChar
        '{'
        (Prelude.showString
           (Data.ProtoLens.showMessageShort __x) (Prelude.showChar '}' __s))
instance Text.PrettyPrint.GenericPretty.Out SocketAddress
instance Data.ProtoLens.Field.HasField SocketAddress "val" Data.Text.Text where
  fieldOf _
    = (Prelude..)
        (Lens.Family2.Unchecked.lens
           _SocketAddress'val (\ x__ y__ -> x__ {_SocketAddress'val = y__}))
        Prelude.id
instance Data.ProtoLens.Message SocketAddress where
  messageName _ = Data.Text.pack "BtcLsp.Newtype.SocketAddress"
  packedMessageDescriptor _
    = "\n\
      \\rSocketAddress\DC2\DLE\n\
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
              Data.ProtoLens.FieldDescriptor SocketAddress
      in
        Data.Map.fromList [(Data.ProtoLens.Tag 1, val__field_descriptor)]
  unknownFields
    = Lens.Family2.Unchecked.lens
        _SocketAddress'_unknownFields
        (\ x__ y__ -> x__ {_SocketAddress'_unknownFields = y__})
  defMessage
    = SocketAddress'_constructor
        {_SocketAddress'val = Data.ProtoLens.fieldDefault,
         _SocketAddress'_unknownFields = []}
  parseMessage
    = let
        loop ::
          SocketAddress -> Data.ProtoLens.Encoding.Bytes.Parser SocketAddress
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
          (do loop Data.ProtoLens.defMessage) "SocketAddress"
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
                         Data.Text.Encoding.encodeUtf8
                         _v))
             (Data.ProtoLens.Encoding.Wire.buildFieldSet
                (Lens.Family2.view Data.ProtoLens.unknownFields _x))
instance Control.DeepSeq.NFData SocketAddress where
  rnf
    = \ x__
        -> Control.DeepSeq.deepseq
             (_SocketAddress'_unknownFields x__)
             (Control.DeepSeq.deepseq (_SocketAddress'val x__) ())
packedFileDescriptor :: Data.ByteString.ByteString
packedFileDescriptor
  = "\n\
    \\NAKbtc_lsp/newtype.proto\DC2\SOBtcLsp.Newtype\"\EM\n\
    \\ENQNonce\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\EOTR\ETXval\"\RS\n\
    \\n\
    \FieldIndex\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\rR\ETXval\"!\n\
    \\rSocketAddress\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXval\"\CAN\n\
    \\EOTMsat\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\EOTR\ETXval\"6\n\
    \\fLocalBalance\DC2&\n\
    \\ETXval\CAN\SOH \SOH(\v2\DC4.BtcLsp.Newtype.MsatR\ETXval\"7\n\
    \\rRemoteBalance\DC2&\n\
    \\ETXval\CAN\SOH \SOH(\v2\DC4.BtcLsp.Newtype.MsatR\ETXval\"\FS\n\
    \\bLnPubKey\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXval\"\GS\n\
    \\tLnInvoice\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXval\"!\n\
    \\rLnHodlInvoice\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXval\"\"\n\
    \\SOOnChainAddress\DC2\DLE\n\
    \\ETXval\CAN\SOH \SOH(\tR\ETXvalJ\178\ACK\n\
    \\ACK\DC2\EOT\NUL\NUL*\SOH\n\
    \\b\n\
    \\SOH\f\DC2\ETX\NUL\NUL\DLE\n\
    \\b\n\
    \\SOH\STX\DC2\ETX\STX\NUL\ETB\n\
    \\n\
    \\n\
    \\STX\EOT\NUL\DC2\EOT\EOT\NUL\ACK\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\NUL\SOH\DC2\ETX\EOT\b\r\n\
    \\v\n\
    \\EOT\EOT\NUL\STX\NUL\DC2\ETX\ENQ\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ENQ\DC2\ETX\ENQ\STX\b\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\SOH\DC2\ETX\ENQ\t\f\n\
    \\f\n\
    \\ENQ\EOT\NUL\STX\NUL\ETX\DC2\ETX\ENQ\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\SOH\DC2\EOT\b\NUL\n\
    \\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\SOH\SOH\DC2\ETX\b\b\DC2\n\
    \\v\n\
    \\EOT\EOT\SOH\STX\NUL\DC2\ETX\t\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ENQ\DC2\ETX\t\STX\b\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\SOH\DC2\ETX\t\t\f\n\
    \\f\n\
    \\ENQ\EOT\SOH\STX\NUL\ETX\DC2\ETX\t\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\STX\DC2\EOT\f\NUL\SO\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\STX\SOH\DC2\ETX\f\b\NAK\n\
    \\v\n\
    \\EOT\EOT\STX\STX\NUL\DC2\ETX\r\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ENQ\DC2\ETX\r\STX\b\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\SOH\DC2\ETX\r\t\f\n\
    \\f\n\
    \\ENQ\EOT\STX\STX\NUL\ETX\DC2\ETX\r\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\ETX\DC2\EOT\DLE\NUL\DC2\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ETX\SOH\DC2\ETX\DLE\b\f\n\
    \\v\n\
    \\EOT\EOT\ETX\STX\NUL\DC2\ETX\DC1\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ENQ\DC2\ETX\DC1\STX\b\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\SOH\DC2\ETX\DC1\t\f\n\
    \\f\n\
    \\ENQ\EOT\ETX\STX\NUL\ETX\DC2\ETX\DC1\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\EOT\DC2\EOT\DC4\NUL\SYN\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\EOT\SOH\DC2\ETX\DC4\b\DC4\n\
    \\v\n\
    \\EOT\EOT\EOT\STX\NUL\DC2\ETX\NAK\STX\SI\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ACK\DC2\ETX\NAK\STX\ACK\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\SOH\DC2\ETX\NAK\a\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\EOT\STX\NUL\ETX\DC2\ETX\NAK\r\SO\n\
    \\n\
    \\n\
    \\STX\EOT\ENQ\DC2\EOT\CAN\NUL\SUB\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ENQ\SOH\DC2\ETX\CAN\b\NAK\n\
    \\v\n\
    \\EOT\EOT\ENQ\STX\NUL\DC2\ETX\EM\STX\SI\n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\ACK\DC2\ETX\EM\STX\ACK\n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\SOH\DC2\ETX\EM\a\n\
    \\n\
    \\f\n\
    \\ENQ\EOT\ENQ\STX\NUL\ETX\DC2\ETX\EM\r\SO\n\
    \\n\
    \\n\
    \\STX\EOT\ACK\DC2\EOT\FS\NUL\RS\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\ACK\SOH\DC2\ETX\FS\b\DLE\n\
    \\v\n\
    \\EOT\EOT\ACK\STX\NUL\DC2\ETX\GS\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ENQ\DC2\ETX\GS\STX\b\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\SOH\DC2\ETX\GS\t\f\n\
    \\f\n\
    \\ENQ\EOT\ACK\STX\NUL\ETX\DC2\ETX\GS\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\a\DC2\EOT \NUL\"\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\a\SOH\DC2\ETX \b\DC1\n\
    \\v\n\
    \\EOT\EOT\a\STX\NUL\DC2\ETX!\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ENQ\DC2\ETX!\STX\b\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\SOH\DC2\ETX!\t\f\n\
    \\f\n\
    \\ENQ\EOT\a\STX\NUL\ETX\DC2\ETX!\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\b\DC2\EOT$\NUL&\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\b\SOH\DC2\ETX$\b\NAK\n\
    \\v\n\
    \\EOT\EOT\b\STX\NUL\DC2\ETX%\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ENQ\DC2\ETX%\STX\b\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\SOH\DC2\ETX%\t\f\n\
    \\f\n\
    \\ENQ\EOT\b\STX\NUL\ETX\DC2\ETX%\SI\DLE\n\
    \\n\
    \\n\
    \\STX\EOT\t\DC2\EOT(\NUL*\SOH\n\
    \\n\
    \\n\
    \\ETX\EOT\t\SOH\DC2\ETX(\b\SYN\n\
    \\v\n\
    \\EOT\EOT\t\STX\NUL\DC2\ETX)\STX\DC1\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\ENQ\DC2\ETX)\STX\b\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\SOH\DC2\ETX)\t\f\n\
    \\f\n\
    \\ENQ\EOT\t\STX\NUL\ETX\DC2\ETX)\SI\DLEb\ACKproto3"