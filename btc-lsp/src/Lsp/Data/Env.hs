{-# LANGUAGE BangPatterns #-}

module Lsp.Data.Env
  ( Env (..),
    RawConfig (..),
    readRawConfig,
    withEnv,
    parseFromJSON,
  )
where

import Control.Monad.Logger (runNoLoggingT)
import Crypto.Cipher.AES (AES256)
import Crypto.Cipher.Types (IV, cipherInit, makeIV)
import Crypto.Error (CryptoFailable (..))
import qualified Data.Aeson as A (Result (..), Value (..), decode)
import Data.ByteString.Char8 as C8S (pack)
import Data.ByteString.Lazy.Char8 as C8L (pack)
import qualified Data.Text.Lazy.Encoding as LTE
import qualified Env as E
  ( Error (..),
    Mod,
    Var,
    auto,
    header,
    help,
    keep,
    nonempty,
    parse,
    str,
    var,
  )
import qualified LndClient as Lnd
import Lsp.Data.Type
import Lsp.Import.External
import qualified Lsp.Import.Psql as Psql

data Env = Env
  { -- | General
    envSQLPool :: Pool Psql.SqlBackend,
    envEndpointPort :: Int,
    -- | Logging
    envKatipNS :: Namespace,
    envKatipCTX :: LogContexts,
    envKatipLE :: LogEnv,
    -- | 32 bytes for AES256
    envCryptoCipher :: AES256,
    -- | 16 bytes for AES256
    envCryptoInitVector :: IV AES256,
    -- | Lnd
    envLnd :: Lnd.LndEnv,
    -- | Grpc
    envGrpcServerEnv :: GSEnv
  }

data RawConfig = RawConfig
  { -- | General
    rawConfigLibpqConnStr :: Psql.ConnectionString,
    rawConfigEndpointPort :: Int,
    -- | Logging
    rawConfigLogEnv :: Text,
    rawConfigLogFormat :: LogFormat,
    rawConfigLogVerbosity :: Verbosity,
    rawConfigLogSeverity :: Severity,
    -- | Encryption
    rawConfigCipher :: AES256,
    rawConfigInitVector :: IV AES256,
    -- | Lnd
    rawConfigLndEnv :: Lnd.LndEnv,
    -- | Grpc
    rawConfigGrpcServerEnv :: GSEnv
  }

-- | Here we enable normal JSON parsing
-- as well as double-quoted JSON parsing
-- which is handy in some devops-related
-- corner cases.
parseFromJSON :: (FromJSON a) => String -> Either E.Error a
parseFromJSON x =
  case A.decode $ C8L.pack x of
    Just (A.String s) ->
      maybeToRight
        ( E.UnreadError
            "parseFromJSON => layer 2 parsing failure"
        )
        $ A.decode $
          LTE.encodeUtf8 $
            fromStrict s
    Just j ->
      case fromJSON j of
        A.Success v -> Right v
        A.Error {} -> failure "parseFromJSON => layer 1 fromJSON failure"
    Nothing ->
      failure "parseFromJSON => layer 1 parsing failure"
  where
    failure = Left . E.UnreadError

parseCipher :: String -> Either E.Error AES256
parseCipher secretKey =
  case cipherInit $ C8S.pack secretKey of
    CryptoFailed {} -> Left $ E.UnreadError "parseCipher => cipherInit failure"
    CryptoPassed a -> Right a

parseInitVector :: String -> Either E.Error (IV AES256)
parseInitVector initVectorString = case makeIV $ C8S.pack initVectorString of
  Just v -> Right v
  Nothing -> Left $ E.UnreadError "parseInitVector => makeIV failure"

readRawConfig :: IO RawConfig
readRawConfig =
  E.parse (E.header "LSP") $
    RawConfig
      -- General
      <$> E.var (E.str <=< E.nonempty) "LSP_LIBPQ_CONN_STR" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_ENDPOINT_PORT" opts
      -- Logging
      <*> E.var (E.str <=< E.nonempty) "LSP_LOG_ENV" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_FORMAT" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_VERBOSITY" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_SEVERITY" opts
      -- Encryption
      <*> E.var (parseCipher <=< E.nonempty) "LSP_AES256_SECRET_KEY" opts
      <*> E.var (parseInitVector <=< E.nonempty) "LSP_AES256_INIT_VECTOR" opts
      -- Lnd
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_LND_ENV" opts
      -- Grpc
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_GRPC_SERVER_ENV" opts
  where
    opts :: E.Mod E.Var a
    opts =
      E.keep <> E.help ""

withEnv ::
  RawConfig ->
  (Env -> KatipContextT IO a) ->
  IO a
withEnv !rc this = do
  handleScribe <-
    mkHandleScribeWithFormatter
      ( case rawConfigLogFormat rc of
          Bracket -> bracketFormat
          JSON -> jsonFormat
      )
      ColorIfTerminal
      stdout
      (permitItem $ rawConfigLogSeverity rc)
      (rawConfigLogVerbosity rc)
  let newLogEnv =
        registerScribe "stdout" handleScribe defaultScribeSettings
          =<< initLogEnv
            "Lsp"
            ( Environment $ rawConfigLogEnv rc
            )
  let newSqlPool :: IO (Pool Psql.SqlBackend) =
        runNoLoggingT $
          Psql.createPostgresqlPool (rawConfigLibpqConnStr rc) 10
  let katipCtx = mempty :: LogContexts
  let katipNs = mempty :: Namespace
  bracket newLogEnv rmLogEnv $ \le ->
    bracket newSqlPool rmSqlPool $ \pool ->
      runKatipContextT le katipCtx katipNs $
        this $
          Env
            { -- General
              envSQLPool = pool,
              envEndpointPort = rawConfigEndpointPort rc,
              -- Logging
              envKatipLE = le,
              envKatipCTX = katipCtx,
              envKatipNS = katipNs,
              -- Encryption
              envCryptoCipher = rawConfigCipher rc,
              envCryptoInitVector = rawConfigInitVector rc,
              -- Lnd
              envLnd = rawConfigLndEnv rc,
              -- Grpc
              envGrpcServerEnv = rawConfigGrpcServerEnv rc
            }
  where
    rmLogEnv :: LogEnv -> IO ()
    rmLogEnv = void . liftIO . closeScribes
    rmSqlPool :: Pool a -> IO ()
    rmSqlPool = liftIO . destroyAllResources
