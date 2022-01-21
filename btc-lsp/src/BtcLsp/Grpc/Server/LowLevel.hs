module BtcLsp.Grpc.Server.LowLevel
  ( GSEnv (..),
    runServer,
    serverApp,
    withSig,
  )
where

import BtcLsp.Grpc.Data
import Control.Exception (throwIO)
import Data.Aeson (FromJSON (..), withObject, (.:))
import qualified Data.CaseInsensitive as CI
import Data.Coerce (coerce)
import Data.Signable (Signable)
import qualified Data.Signable as Signable
import qualified Data.Text.Encoding as TE
import Network.GRPC.HTTP2.Encoding (gzip)
import Network.GRPC.HTTP2.Types (GRPCStatus (..), GRPCStatusCode (UNAUTHENTICATED))
import Network.GRPC.Server
import Network.GRPC.Server.Wai (grpcApp)
import Network.HTTP2.Server hiding (Request (..))
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Handler.WarpTLS (runTLS, tlsSettingsMemory)
import Network.Wai.Internal (Request (..))
import Universum

data GSEnv = GSEnv
  { gsEnvPort :: Int,
    gsEnvPrvKey :: PrvKey 'Server,
    gsEnvPubKey :: PubKey 'Client,
    gsEnvSigHeaderName :: SigHeaderName,
    gsEnvTlsCert :: TlsCert 'Server,
    gsEnvTlsKey :: TlsKey 'Server,
    gsEnvLogger :: Text -> IO ()
  }
  deriving (Generic)

instance FromJSON GSEnv where
  parseJSON =
    withObject
      "GSEnv"
      ( \x ->
          GSEnv
            <$> x .: "port"
            <*> x .: "prv_key"
            <*> x .: "pub_key"
            <*> x .: "sig_header_name"
            <*> x .: "tls_cert"
            <*> x .: "tls_key"
            <*> pure (const $ pure ())
      )

runServer :: GSEnv -> (GSEnv -> MVar (Sig 'Server) -> [ServiceHandler]) -> IO ()
runServer env handlers =
  runTLS
    ( tlsSettingsMemory
        (TE.encodeUtf8 . coerce $ gsEnvTlsCert env)
        (TE.encodeUtf8 . coerce $ gsEnvTlsKey env)
    )
    (setPort (gsEnvPort env) defaultSettings)
    (serverApp env $ handlers env)

serverApp :: GSEnv -> (MVar (Sig 'Server) -> [ServiceHandler]) -> Application
serverApp env handlers req rep = do
  sigVar <- newEmptyMVar
  let app = grpcApp [gzip] $ handlers sigVar
  app req (middleware sigVar)
  where
    sigHeaderName = coerce $ gsEnvSigHeaderName env
    middleware sigVar res = do
      modifyHTTP2Data req $ \http2data0 ->
        let http2data = fromMaybe defaultHTTP2Data http2data0
         in Just $
              http2data
                { http2dataTrailers = trailersMaker sigVar (http2dataTrailers http2data)
                }
      rep $ mapResponseHeaders (\hs -> ("trailer", sigHeaderName) : hs) res
    trailersMaker sigVar oldMaker Nothing = do
      ts <- oldMaker Nothing
      case ts of
        Trailers ss -> do
          mSig <- tryTakeMVar sigVar
          pure $ case mSig of
            Nothing -> ts
            Just sig ->
              Trailers $
                (CI.mk sigHeaderName, Signable.exportSigDer $ coerce sig) : ss
        NextTrailersMaker {} ->
          --
          -- TODO : throwIO GRPCStatus
          --
          error "UNEXPECTED_NEW_TRAILERS_MAKER"
    trailersMaker sigVar oldMaker _ =
      pure $ NextTrailersMaker (trailersMaker sigVar oldMaker)

withSig ::
  ( Signable req,
    Signable res
  ) =>
  GSEnv ->
  MVar (Sig 'Server) ->
  (req -> IO res) ->
  Request ->
  req ->
  IO res
withSig env sigVar handler httpReq protoReq =
  case find (\x -> fst x == sigHeaderNameCI) $ requestHeaders httpReq of
    Nothing -> failure $ sigHeaderName <> " is missing"
    Just (_, rawClientSig) ->
      case Signable.importSigDer Signable.AlgSecp256k1 rawClientSig of
        Nothing -> failure $ sigHeaderName <> " import failed"
        Just clientSig ->
          if not (verify (gsEnvPubKey env) (Sig clientSig) protoReq)
            then failure $ sigHeaderName <> " verification failed"
            else do
              res <- handler protoReq
              let sig = sign (gsEnvPrvKey env) res
              putMVar sigVar sig
              pure res
  where
    failure = throwIO . GRPCStatus UNAUTHENTICATED
    sigHeaderName = coerce $ gsEnvSigHeaderName env
    sigHeaderNameCI = CI.mk sigHeaderName
