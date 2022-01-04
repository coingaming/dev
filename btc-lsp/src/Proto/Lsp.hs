{- This file was auto-generated from lsp.proto by the proto-lens-protoc program. -}
{-# LANGUAGE ScopedTypeVariables, DataKinds, TypeFamilies, UndecidableInstances, GeneralizedNewtypeDeriving, MultiParamTypeClasses, FlexibleContexts, FlexibleInstances, PatternSynonyms, MagicHash, NoImplicitPrelude, BangPatterns, TypeApplications, OverloadedStrings, DerivingStrategies, DeriveGeneric#-}
{-# OPTIONS_GHC -Wno-unused-imports#-}
{-# OPTIONS_GHC -Wno-duplicate-exports#-}
{-# OPTIONS_GHC -Wno-dodgy-exports#-}
module Proto.Lsp (
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
import qualified Proto.Lsp.Custody.DepositLn
import qualified Proto.Lsp.Custody.DepositOnChain
data Service = Service {}
instance Data.ProtoLens.Service.Types.Service Service where
  type ServiceName Service = "Service"
  type ServicePackage Service = "Lsp"
  type ServiceMethods Service = '["custodyDepositLn",
                                  "custodyDepositOnChain"]
  packedServiceDescriptor _
    = "\n\
      \\aService\DC2b\n\
      \\NAKCustodyDepositOnChain\DC2#.Lsp.Custody.DepositOnChain.Request\SUB$.Lsp.Custody.DepositOnChain.Response\DC2S\n\
      \\DLECustodyDepositLn\DC2\RS.Lsp.Custody.DepositLn.Request\SUB\US.Lsp.Custody.DepositLn.Response"
instance Data.ProtoLens.Service.Types.HasMethodImpl Service "custodyDepositOnChain" where
  type MethodName Service "custodyDepositOnChain" = "CustodyDepositOnChain"
  type MethodInput Service "custodyDepositOnChain" = Proto.Lsp.Custody.DepositOnChain.Request
  type MethodOutput Service "custodyDepositOnChain" = Proto.Lsp.Custody.DepositOnChain.Response
  type MethodStreamingType Service "custodyDepositOnChain" =  'Data.ProtoLens.Service.Types.NonStreaming
instance Data.ProtoLens.Service.Types.HasMethodImpl Service "custodyDepositLn" where
  type MethodName Service "custodyDepositLn" = "CustodyDepositLn"
  type MethodInput Service "custodyDepositLn" = Proto.Lsp.Custody.DepositLn.Request
  type MethodOutput Service "custodyDepositLn" = Proto.Lsp.Custody.DepositLn.Response
  type MethodStreamingType Service "custodyDepositLn" =  'Data.ProtoLens.Service.Types.NonStreaming