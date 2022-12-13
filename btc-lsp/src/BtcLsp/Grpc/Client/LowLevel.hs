module BtcLsp.Grpc.Client.LowLevel
  ( runUnary,
    GCEnv (..),
    GCPort (..),
  )
where

import BtcLsp.Grpc.Data
import BtcLsp.Grpc.Orphan ()
import qualified BtcLsp.Grpc.Sig as Sig
import BtcLsp.Import.Witch
import Data.Aeson
  ( FromJSON (..),
    withObject,
    withScientific,
    (.:),
    (.:?),
  )
import qualified Data.Binary.Builder as BS
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.ByteString.Lazy as BL
import qualified Data.CaseInsensitive as CI
import Data.ProtoLens (Message)
import Data.ProtoLens.Encoding (encodeMessage)
import Data.ProtoLens.Service.Types (HasMethod, HasMethodImpl (..))
import Data.Scientific (floatingOrInteger)
import GHC.TypeLits (Symbol)
import Network.GRPC.Client
import Network.GRPC.Client.Helpers
import qualified Network.GRPC.HTTP2.Encoding as G
import qualified Network.GRPC.HTTP2.ProtoLens as ProtoLens
import Network.HTTP2.Client2
import Text.PrettyPrint.GenericPretty
  ( Out,
  )
import Text.PrettyPrint.GenericPretty.Import
  ( inspectPlain,
  )
import Universum

data GCEnv = GCEnv
  { gcEnvHost :: String,
    gcEnvPort :: GCPort,
    gcEnvEncryption :: Maybe Encryption,
    gcEnvSigHeaderName :: SigHeaderName,
    gcEnvCompressMode :: CompressMode,
    gcEnvSigner :: Sig.MsgToSign -> IO (Maybe Sig.LndSig)
  }
  deriving stock
    ( Generic
    )

instance FromJSON GCEnv where
  parseJSON =
    withObject
      "GCEnv"
      ( \x ->
          GCEnv
            <$> x .: "host"
            <*> x .: "port"
            <*> x .:? "encryption"
            <*> x .: "sig_header_name"
            <*> x .: "compress_mode"
            <*> pure (const $ pure Nothing)
      )

newtype GCPort = GCPort {unGCPort :: PortNumber}
  deriving newtype
    ( Enum,
      Eq,
      Integral,
      Num,
      Ord,
      Read,
      Real,
      Show
    )

instance FromJSON GCPort where
  parseJSON =
    withScientific "GCPort" $ \x0 ->
      case floatingOrInteger x0 of
        Left (_ :: Double) -> fail "Non-integer"
        Right x -> pure x

runUnary ::
  ( Out res,
    Show res,
    HasMethod s m,
    req ~ MethodInput s m,
    res ~ MethodOutput s m
  ) =>
  ProtoLens.RPC s (m :: Symbol) ->
  GCEnv ->
  (res -> ByteString -> CompressMode -> IO Bool) ->
  req ->
  IO (Either Text res)
runUnary rpc env verifySig req = do
  res <-
    runClientIO $
      bracket
        ( makeClient env req
            . maybe True (== Encrypted)
            $ gcEnvEncryption env
        )
        close
        (\grpc -> rawUnary rpc grpc req)
  case res of
    Right (Right (Right (h, mh, Right x))) ->
      case find (\header -> fst header == sigHeaderName) $ h <> fromMaybe mempty mh of
        Nothing ->
          pure . Left $
            "Client ==> missing server header "
              <> inspectPlain sigHeaderName
        Just (_, b64sig) -> do
          let sigDer = B64.decodeLenient b64sig
          isVerified <-
            verifySig x sigDer $
              gcEnvCompressMode env
          pure $
            if isVerified
              then Right x
              else
                Left $
                  "Client ==> server signature verification"
                    <> " failed for raw bytes"
                    <> " from decoded payload "
                    <> inspectPlain x
                    <> " with signature "
                    <> inspectPlain sigDer
    x ->
      pure . Left $
        "Client ==> server grpc failure "
          <> Universum.show x
  where
    sigHeaderName = CI.mk . from $ gcEnvSigHeaderName env

msgToSignBytes ::
  ( Message msg
  ) =>
  CompressMode ->
  msg ->
  ByteString
msgToSignBytes compressMode msg = header <> body
  where
    rawBody = encodeMessage msg
    body =
      case compressMode of
        Compressed -> G._compressionFunction G.gzip rawBody
        Uncompressed -> rawBody
    header =
      BS.pack
        [ case compressMode of
            Compressed -> 1
            Uncompressed -> 0
        ]
        <> ( BL.toStrict
               . BS.toLazyByteString
               . BS.putWord32be
               . fromIntegral -- Length is non-neg, it's fine.
               $ BS.length body
           )

makeClient ::
  Message req =>
  GCEnv ->
  req ->
  UseTlsOrNot ->
  ClientIO GrpcClient
makeClient env req tlsEnabled = do
  mSignature <- liftIO doSignature
  case mSignature of
    Just signature ->
      setupGrpcClient $
        (grpcClientConfigSimple (gcEnvHost env) (unGCPort $ gcEnvPort env) tlsEnabled)
          { _grpcClientConfigCompression = compression,
            _grpcClientConfigHeaders =
              [ ( sigHeaderName,
                  B64.encode $ Sig.unLndSig signature
                )
              ]
          }
    Nothing -> throwError EarlyEndOfStream
  where
    signer = gcEnvSigner env
    sigHeaderName = from $ gcEnvSigHeaderName env
    compressMode = gcEnvCompressMode env
    doSignature =
      signer . Sig.MsgToSign $
        msgToSignBytes compressMode req
    compression =
      case compressMode of
        Compressed -> gzip
        Uncompressed -> uncompressed
