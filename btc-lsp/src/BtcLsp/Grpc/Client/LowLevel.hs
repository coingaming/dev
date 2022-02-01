module BtcLsp.Grpc.Client.LowLevel
  ( runUnary,
    GCEnv (..),
    GCPort (..),
  )
where

import BtcLsp.Grpc.Data
import Data.Aeson
  ( FromJSON (..),
    camelTo2,
    defaultOptions,
    fieldLabelModifier,
    genericParseJSON,
    withScientific,
  )
import qualified Data.ByteString.Lazy as BL
import qualified Data.CaseInsensitive as CI
import Data.Coerce (coerce)
import Data.ProtoLens.Service.Types (HasMethod, HasMethodImpl (..))
import Data.Scientific (floatingOrInteger)
import GHC.TypeLits (Symbol)
import Network.GRPC.Client
import Network.GRPC.Client.Helpers
import Network.GRPC.HTTP2.Encoding (gzip)
import qualified Network.GRPC.HTTP2.ProtoLens as ProtoLens
import Network.HTTP2.Client
import Text.PrettyPrint.GenericPretty
  ( Out,
  )
import Text.PrettyPrint.GenericPretty.Import
  ( inspectPlain,
  )
import Universum
import Data.ProtoLens (Message)
import qualified Network.GRPC.HTTP2.Encoding as G
import qualified Data.ByteString as BS
import qualified Data.Binary.Builder as BS
import Data.ProtoLens.Encoding (encodeMessage)
import BtcLsp.Grpc.Server.LowLevel (GSEnv (gsEnvSigner))

data GCEnv = GCEnv
  { gcEnvHost :: String,
    gcEnvPort :: GCPort,
    gcEnvSigHeaderName :: SigHeaderName
  }
  deriving (Eq, Generic)

instance FromJSON GCEnv where
  parseJSON =
    genericParseJSON
      defaultOptions
        { fieldLabelModifier = camelTo2 '_' . drop 5
        }

newtype GCPort
  = GCPort PortNumber
  deriving
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
  GSEnv ->
  GCEnv ->
  (res -> ByteString -> IO Bool) ->
  req ->
  IO (Either Text res)
runUnary rpc gsEnv env verifySig req = do
  res <-
    runClientIO $
      bracket
        (makeClient gsEnv env req True True)
        close
        (\grpc -> rawUnary rpc grpc req)
  case res of
    Right (Right (Right (h, mh, Right x))) ->
      case find (\header -> fst header == sigHeaderName) $ h <> fromMaybe mempty mh of
        Nothing ->
          pure . Left $
            "Client ==> missing server header "
              <> inspectPlain sigHeaderName
        Just (_, rawSig) -> do
          isVerified <- verifySig x rawSig
          pure $
            if isVerified
              then Right x
              else
                Left $
                  "Client ==> server signature verification failed for raw bytes "
                    <> " from decoded payload "
                    <> inspectPlain x
                    <> " with signature "
                    <> inspectPlain rawSig
    x ->
      --
      -- TODO : replace show with inspectPlain
      -- need additional instances for this.
      --
      pure . Left $
        "Client ==> server grpc failure "
          <> show x
  where
    sigHeaderName = CI.mk . coerce $ gcEnvSigHeaderName env

msgToSignBytes :: (Message msg) => Bool -> msg -> ByteString
msgToSignBytes doCompress msg = header <> body
  where
    rawBody = encodeMessage msg
    body = if doCompress
              then G._compressionFunction G.gzip rawBody
              else rawBody
    header =  BS.pack [1]
          <> ( BL.toStrict
               . BS.toLazyByteString
               . BS.putWord32be
               . fromIntegral
               $ BS.length body
             )


makeClient ::
  Message req =>
  GSEnv ->
  GCEnv ->
  req ->
  UseTlsOrNot ->
  Bool ->
  ClientIO GrpcClient
makeClient gsEnv env req tlsEnabled doCompress = do
  mSignature <- liftIO doSignature
  case mSignature of
    Just signature ->
      setupGrpcClient $
        (grpcClientConfigSimple (gcEnvHost env) (coerce $ gcEnvPort env) tlsEnabled)
          { _grpcClientConfigCompression = compression,
            _grpcClientConfigHeaders = [(sigHeaderName, signature)]
          }
    Nothing -> throwError EarlyEndOfStream
  where
    signer = gsEnvSigner gsEnv
    sigHeaderName = coerce $ gcEnvSigHeaderName env
    doSignature = signer $ msgToSignBytes doCompress req
    compression = if doCompress then gzip else uncompressed
