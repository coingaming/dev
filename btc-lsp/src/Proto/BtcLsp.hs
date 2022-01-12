{- This file was auto-generated from btc_lsp.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.BtcLsp (
        Service(..)
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
import qualified Proto.BtcLsp.Method.GetCfg
import qualified Proto.BtcLsp.Method.SwapFromLn
import qualified Proto.BtcLsp.Method.SwapIntoLn
data Service = Service {}
instance Data.ProtoLens.Service.Types.Service Service where
  type ServiceName Service = "Service"
  type ServicePackage Service = "BtcLsp"
  type ServiceMethods Service = '["getCfg",
                                  "swapFromLn",
                                  "swapIntoLn"]
  packedServiceDescriptor _
    = "\n\
      \\aService\DC2G\n\
      \\ACKGetCfg\DC2\GS.BtcLsp.Method.GetCfg.Request\SUB\RS.BtcLsp.Method.GetCfg.Response\DC2S\n\
      \\n\
      \SwapIntoLn\DC2!.BtcLsp.Method.SwapIntoLn.Request\SUB\".BtcLsp.Method.SwapIntoLn.Response\DC2S\n\
      \\n\
      \SwapFromLn\DC2!.BtcLsp.Method.SwapFromLn.Request\SUB\".BtcLsp.Method.SwapFromLn.Response"
instance Data.ProtoLens.Service.Types.HasMethodImpl Service "getCfg" where
  type MethodName Service "getCfg" = "GetCfg"
  type MethodInput Service "getCfg" = Proto.BtcLsp.Method.GetCfg.Request
  type MethodOutput Service "getCfg" = Proto.BtcLsp.Method.GetCfg.Response
  type MethodStreamingType Service "getCfg" =  'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Service "swapIntoLn" where
  type MethodName Service "swapIntoLn" = "SwapIntoLn"
  type MethodInput Service "swapIntoLn" = Proto.BtcLsp.Method.SwapIntoLn.Request
  type MethodOutput Service "swapIntoLn" = Proto.BtcLsp.Method.SwapIntoLn.Response
  type MethodStreamingType Service "swapIntoLn" =  'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Service "swapFromLn" where
  type MethodName Service "swapFromLn" = "SwapFromLn"
  type MethodInput Service "swapFromLn" = Proto.BtcLsp.Method.SwapFromLn.Request
  type MethodOutput Service "swapFromLn" = Proto.BtcLsp.Method.SwapFromLn.Response
  type MethodStreamingType Service "swapFromLn" =  'Data.ProtoLens.Service.Types.NonStreaming