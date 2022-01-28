{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# OPTIONS_GHC -Wno-deprecations #-}
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
import qualified Data.ByteString.Lazy as BSL
import qualified Crypto.Secp256k1 as C
import qualified Data.PEM as P
import Universum
import qualified Data.ASN1.Encoding as ASN1
import qualified Data.ASN1.BinaryEncoding as ASN1
import qualified Data.ASN1.Prim as ASN1
import qualified Data.ASN1.BitArray as ASN1

newtype PubKeyPem = PubKeyPem Text
  deriving newtype (Eq, Show, FromJSON)

data GSEnv = GSEnv
  { gsEnvPort :: Int,
    gsEnvPrvKey :: PrvKey 'Server,
    gsEnvPubKey :: PubKey 'Client,
    gsEnvPubKeyPem :: PubKeyPem,
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
            <*> x .: "prv_key"
            <*> x .: "pub_key"
            <*> x .: "pub_key"
            <*> x .: "sig_header_name"
            <*> x .: "tls_cert"
            <*> x .: "tls_key"
            <*> pure (const $ pure ())
            <*> pure (const $ pure Nothing)
      )

runServer :: GSEnv -> (GSEnv -> MVar (Sig 'Server) -> [ServiceHandler]) -> IO ()
runServer env handlers =
  runTLS
    ( tlsSettingsMemory
        (TE.encodeUtf8 . coerce $ gsEnvTlsCert env)
        (TE.encodeUtf8 . coerce $ gsEnvTlsKey env)
    )
    (setPort (gsEnvPort env) defaultSettings)
    (sigCheckMiddleware env $ serverApp env $ handlers env)

serverApp :: GSEnv -> (MVar (Sig 'Server) -> [ServiceHandler]) -> Application
serverApp env handlers req rep = do
  --
  -- TODO : remove sig var!!!!!!
  --
  sigVar <- newEmptyMVar
  let app = grpcApp [gzip] $ handlers sigVar
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

sigFromReq :: ByteString -> Request -> Maybe C.Sig
sigFromReq sigHeaderName req = do
  let sigHeaderNameCI = CI.mk sigHeaderName
  (_, sig) <- find (\x -> fst x == sigHeaderNameCI) $ requestHeaders req
  C.importSig sig

safeHeadEither :: [a] -> Either String a
safeHeadEither [x] = Right x
safeHeadEither _ = Left "Not one chunk"

parsePubKeyPem :: ByteString -> Either String C.PubKey
parsePubKeyPem pbs = do
  pem <- P.pemParseBS pbs >>= safeHeadEither
  asns <- first show $ ASN1.decodeASN1 ASN1.DER (BSL.fromStrict $ P.pemContent pem)
  der <- safeHeadEither asns >>= bitStr
  maybeToRight "Failed to import der" $ C.importPubKey der
    where
      bitStr (ASN1.BitString (ASN1.BitArray _ x)) = Right x
      bitStr _ = Left "Incorrect asn1 object type"
--
-- TODO: FromJSON instance
pubKeyFromEnv :: GSEnv -> Either String C.PubKey
pubKeyFromEnv env = parsePubKeyPem $ TE.encodeUtf8 $ coerce $ gsEnvPubKeyPem env

verifySig :: GSEnv -> Request -> ByteString -> Either String Bool
verifySig env req payload = do
  pubKey <- pubKeyFromEnv env
  sig <- maybeToRight "Incorrect signature" $ sigFromReq sigHeaderName req
  msg <- maybeToRight "Incorrect message" $ C.msg payload
  if C.verifySig pubKey sig msg then Right True else Left "Signature verification fail"
    where
      sigHeaderName = coerce $ gsEnvSigHeaderName env

sigCheckMiddleware :: GSEnv -> Middleware
sigCheckMiddleware env app req resp = do
  body <- BSL.toStrict <$> strictRequestBody req
  case verifySig env req body of
    Right True -> app req { requestBody = pure body } resp
    _ -> app req resp

withSig ::
  ( Signable res
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
    Just (_, _) -> do
      -- case Signable.importSigDer Signable.AlgSecp256k1 rawClientSig of
      --   Nothing -> failure $ sigHeaderName <> " import failed"
      --   Just clientSig ->
      --     if not (verify (gsEnvPubKey env) (Sig clientSig) protoReq)
      --       then failure $ sigHeaderName <> " verification failed"
      --       else do
      res <- handler protoReq
      let sig = sign (gsEnvPrvKey env) res
      putMVar sigVar sig
      pure res
  where
    failure =
      throwIO
        . GRPCStatus UNAUTHENTICATED
        . ("Server ==> " <>)
    sigHeaderName =
      coerce $ gsEnvSigHeaderName env
    sigHeaderNameCI =
      CI.mk sigHeaderName
