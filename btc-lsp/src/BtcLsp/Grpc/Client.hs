{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Grpc.Client
  ( runUnary,
    GCEnv (..),
    GCPort (..),
    swapIntoLn,
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
import qualified Data.CaseInsensitive as CI
import Data.Coerce (coerce)
import Data.ProtoLens.Service.Types (HasMethod, HasMethodImpl (..))
import Data.Scientific (floatingOrInteger)
import Data.Signable (Signable)
import qualified Data.Signable as Signable
import GHC.TypeLits (Symbol)
import Network.GRPC.Client
import Network.GRPC.Client.Helpers
import Network.GRPC.HTTP2.Encoding (gzip)
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import qualified Network.GRPC.HTTP2.ProtoLens as ProtoLens
import Network.HTTP2.Client
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import Proto.SignableOrphan ()
import Universum

data GCEnv = GCEnv
  { gcEnvHost :: String,
    gcEnvPort :: GCPort,
    gcEnvPrvKey :: PrvKey 'Client,
    gcEnvPubKey :: PubKey 'Server,
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

--
-- Low Level
--

runUnary ::
  ( Show res,
    Signable res,
    Signable req,
    HasMethod s m,
    req ~ MethodInput s m,
    res ~ MethodOutput s m
  ) =>
  ProtoLens.RPC s (m :: Symbol) ->
  GCEnv ->
  req ->
  IO (Either Text res)
runUnary rpc env req = do
  res <-
    runClientIO $
      bracket
        (makeClient env req True True)
        close
        (\grpc -> rawUnary rpc grpc req)
  pure $ case res of
    Right (Right (Right (h, mh, Right x))) ->
      case find (\header -> fst header == sigHeaderName) $ h <> fromMaybe mempty mh of
        Nothing -> Left $ "Missing header " <> show sigHeaderName
        Just (_, rawSig) ->
          case Signable.importSigDer Signable.AlgSecp256k1 rawSig of
            Nothing -> Left $ "Secp256k1 sig import error for " <> show rawSig
            Just sig ->
              if verify (gcEnvPubKey env) (Sig sig) x
                then Right x
                else Left $ "Signature verification failed " <> show rawSig
    x ->
      Left $ show x
  where
    sigHeaderName = CI.mk . coerce $ gcEnvSigHeaderName env

makeClient ::
  Signable req =>
  GCEnv ->
  req ->
  UseTlsOrNot ->
  Bool ->
  ClientIO GrpcClient
makeClient env req tlsEnabled doCompress =
  setupGrpcClient $
    (grpcClientConfigSimple (gcEnvHost env) (coerce $ gcEnvPort env) tlsEnabled)
      { _grpcClientConfigCompression = compression,
        _grpcClientConfigHeaders = [(sigHeaderName, signature)]
      }
  where
    sigHeaderName = coerce $ gcEnvSigHeaderName env
    signature = Signable.exportSigDer . coerce $ sign (gcEnvPrvKey env) req
    compression = if doCompress then gzip else uncompressed

--
-- High Level
--
-- TODO : move into separate module
--

swapIntoLn ::
  ( MonadIO m
  ) =>
  GCEnv ->
  SwapIntoLn.Request ->
  m (Either Text SwapIntoLn.Response)
swapIntoLn env req =
  liftIO $
    runUnary (RPC :: RPC Service "swapIntoLn") env req
