{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BtcLsp.Grpc.Server.LowLevel
  ( GSEnv (..),
    runServer,
    serverApp,
  )
where

import BtcLsp.Grpc.Data
import BtcLsp.Import.Witch
import Control.Concurrent (modifyMVar)
import Data.Aeson (FromJSON (..), withObject, (.:))
import qualified Data.ByteString.Base64.URL as B64
import qualified Data.ByteString.Lazy as BSL
import qualified Data.CaseInsensitive as CI
import Data.Coerce (coerce)
import qualified Data.Text.Encoding as TE
import Network.GRPC.HTTP2.Encoding (gzip)
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
    gsEnvSigVerify :: Bool,
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
            <*> x .: "sig_verify"
            <*> x .: "sig_header_name"
            <*> x .: "tls_cert"
            <*> x .: "tls_key"
            <*> pure (const $ pure ())
            <*> pure (const $ pure Nothing)
      )

runServer :: GSEnv -> (GSEnv -> RawRequestBytes -> [ServiceHandler]) -> IO ()
runServer env handlers =
  runTLS
    ( tlsSettingsMemory
        (TE.encodeUtf8 . coerce $ gsEnvTlsCert env)
        (TE.encodeUtf8 . coerce $ gsEnvTlsKey env)
    )
    (setPort (gsEnvPort env) defaultSettings)
    $ if gsEnvSigVerify env
      then extractBodyBytesMiddleware env $ serverApp handlers
      else serverApp handlers env (RawRequestBytes mempty)

serverApp :: (GSEnv -> RawRequestBytes -> [ServiceHandler]) -> GSEnv -> RawRequestBytes -> Application
serverApp handlers env body req rep = do
  --
  -- TODO : remove sig var!!!!!!
  --
  let app = grpcApp [gzip] $ handlers env body
  app req middleware
  where
    sigHeaderName =
      from $ gsEnvSigHeaderName env
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
              Trailers $
                ( CI.mk sigHeaderName,
                  B64.encodeUnpadded sig
                ) :
                ss
        NextTrailersMaker {} ->
          --
          -- TODO : throwIO GRPCStatus
          --
          error "UNEXPECTED_NEW_TRAILERS_MAKER"
    trailersMaker acc oldMaker (Just bs) = do
      pure
        . NextTrailersMaker
        $ trailersMaker (acc <> bs) oldMaker

extractBodyBytesMiddleware :: GSEnv -> (GSEnv -> RawRequestBytes -> Application) -> Application
extractBodyBytesMiddleware env app req resp = do
  body <- BSL.toStrict <$> strictRequestBody req
  body' <- newMVar body
  app env (RawRequestBytes body) (req' body') resp
  where
    requestBody' mvar =
      modifyMVar
        mvar
        ( \b ->
            pure $
              if b == mempty
                then (mempty, mempty)
                else (mempty, b)
        )
    req' b =
      req
        { requestBody = requestBody' b
        }
