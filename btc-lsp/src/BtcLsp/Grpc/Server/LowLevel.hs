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
import qualified Data.Text.Encoding as TE
import Network.GRPC.HTTP2.Encoding (gzip)
import Network.GRPC.HTTP2.Types
  ( GRPCStatus (..),
    GRPCStatusCode (UNAUTHENTICATED),
  )
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
    gsEnvSigHeaderName :: SigHeaderName,
    gsEnvTlsCert :: TlsCert 'Server,
    gsEnvTlsKey :: TlsKey 'Server,
    gsEnvLogger :: Text -> IO (),
    --
    -- TODO : more typed data
    --
    gsEnvSigner :: ByteString -> IO (Maybe ByteString)
  }
  deriving (Generic)

instance FromJSON GSEnv where
  parseJSON =
    withObject
      "GSEnv"
      ( \x ->
          GSEnv
            <$> x .: "port"
            <*> x .: "sig_header_name"
            <*> x .: "tls_cert"
            <*> x .: "tls_key"
            <*> pure (const $ pure ())
            <*> pure (const $ pure Nothing)
      )

runServer :: GSEnv -> (GSEnv -> [ServiceHandler]) -> IO ()
runServer env handlers =
  runTLS
    ( tlsSettingsMemory
        (TE.encodeUtf8 . coerce $ gsEnvTlsCert env)
        (TE.encodeUtf8 . coerce $ gsEnvTlsKey env)
    )
    (setPort (gsEnvPort env) defaultSettings)
    (serverApp env $ handlers env)

serverApp :: GSEnv -> [ServiceHandler] -> Application
serverApp env handlers req rep = do
  let app = grpcApp [gzip] handlers
  app req middleware
  where
    sigHeaderName = coerce $ gsEnvSigHeaderName env
    middleware res = do
      modifyHTTP2Data req $ \http2data0 ->
        let http2data = fromMaybe defaultHTTP2Data http2data0
         in Just $
              http2data
                { http2dataTrailers =
                    trailersMaker
                      mempty
                      (http2dataTrailers http2data)
                }
      rep $
        mapResponseHeaders
          (\hs -> ("trailer", sigHeaderName) : hs)
          res
    trailersMaker acc oldMaker Nothing = do
      ts <- oldMaker Nothing
      case ts of
        Trailers ss -> do
          mSig <- gsEnvSigner env acc
          pure $ case mSig of
            Nothing ->
              ts
            Just sig ->
              Trailers $ (CI.mk sigHeaderName, sig) : ss
        NextTrailersMaker {} ->
          --
          -- TODO : throwIO GRPCStatus
          --
          error "UNEXPECTED_NEW_TRAILERS_MAKER"
    trailersMaker acc oldMaker (Just bs) = do
      pure
        . NextTrailersMaker
        $ trailersMaker (acc <> bs) oldMaker

withSig ::
  GSEnv ->
  (req -> IO res) ->
  Request ->
  req ->
  IO res
withSig env handler httpReq protoReq =
  case find (\x -> fst x == sigHeaderNameCI) $ requestHeaders httpReq of
    Nothing -> failure $ sigHeaderName <> " is missing"
    Just (_, _) -> do
      -- case Signable.importSigDer Signable.AlgSecp256k1 rawClientSig of
      --   Nothing -> failure $ sigHeaderName <> " import failed"
      --   Just clientSig ->
      --     if not (verify (gsEnvPubKey env) (Sig clientSig) protoReq)
      --       then failure $ sigHeaderName <> " verification failed"
      --       else do
      handler protoReq
  where
    failure =
      throwIO
        . GRPCStatus UNAUTHENTICATED
        . ("Server ==> " <>)
    sigHeaderName =
      coerce $ gsEnvSigHeaderName env
    sigHeaderNameCI =
      CI.mk sigHeaderName
