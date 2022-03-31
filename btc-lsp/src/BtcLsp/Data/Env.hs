{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Data.Env
  ( Env (..),
    RawConfig (..),
    readRawConfig,
    readGCEnv,
    withEnv,
    parseFromJSON,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Grpc.Server.LowLevel
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Math as Math
import BtcLsp.Rpc.Env
import Control.Monad.Logger (runNoLoggingT)
import qualified Data.Aeson as A (Result (..), Value (..), decode)
import qualified Data.ByteString as BS
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
import qualified LndClient.Data.SignMessage as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc

data Env = Env
  { -- | General
    envSQLPool :: Pool Psql.SqlBackend,
    -- | Logging
    envKatipNS :: Namespace,
    envKatipCTX :: LogContexts,
    envKatipLE :: LogEnv,
    -- | Lnd
    envLnd :: Lnd.LndEnv,
    envLndP2PHost :: HostName,
    envLndP2PPort :: PortNumber,
    envSwapIntoLnMinAmt :: Money 'Usr 'OnChain 'Fund,
    envMsatPerByte :: Maybe MSat,
    envLndPubKey :: MVar Lnd.NodePubKey,
    -- | Grpc
    envGrpcServer :: GSEnv,
    -- | Elecrts
    envElectrs :: Maybe ElectrsEnv,
    -- | Bitcoind
    envBtc :: Btc.Client
  }

data RawConfig = RawConfig
  { -- | General
    rawConfigLibpqConnStr :: Psql.ConnectionString,
    -- | Logging
    rawConfigLogEnv :: Text,
    rawConfigLogFormat :: LogFormat,
    rawConfigLogVerbosity :: Verbosity,
    rawConfigLogSeverity :: Severity,
    -- | Lnd
    rawConfigLndEnv :: Lnd.LndEnv,
    rawConfigLndP2PHost :: HostName,
    rawConfigLndP2PPort :: PortNumber,
    rawConfigMinChanCap :: Money 'Chan 'Ln 'Fund,
    rawConfigMsatPerByte :: Maybe MSat,
    -- | Grpc
    rawConfigGrpcServerEnv :: GSEnv,
    -- | Electrs Rpc
    rawConfigElectrsEnv :: Maybe ElectrsEnv,
    -- | Bitcoind
    rawConfigBtcEnv :: BitcoindEnv
  }

--
-- TODO : do we really need support of
-- double-quoted JSONs now???
--

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

readRawConfig :: IO RawConfig
readRawConfig =
  E.parse (E.header "BtcLsp") $
    RawConfig
      -- General
      <$> E.var (E.str <=< E.nonempty) "LSP_LIBPQ_CONN_STR" opts
      -- Logging
      <*> E.var (E.str <=< E.nonempty) "LSP_LOG_ENV" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_FORMAT" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_VERBOSITY" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LOG_SEVERITY" opts
      -- Lnd
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_LND_ENV" opts
      <*> E.var (E.str <=< E.nonempty) "LSP_LND_P2P_HOST" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_LND_P2P_PORT" opts
      <*> E.var (E.auto <=< E.nonempty) "LSP_MIN_CHAN_CAP_MSAT" opts
      <*> optional (E.var (E.auto <=< E.nonempty) "LSP_MSAT_PER_BYTE" opts)
      -- Grpc
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_GRPC_SERVER_ENV" opts
      -- Electrs
      --
      -- TODO : move into separate package
      --
      <*> optional (E.var (parseFromJSON <=< E.nonempty) "LSP_ELECTRS_ENV" opts)
      -- Bitcoind
      <*> E.var (parseFromJSON <=< E.nonempty) "LSP_BITCOIND_ENV" opts

readGCEnv :: IO GCEnv
readGCEnv =
  E.parse (E.header "GCEnv") $
    E.var (parseFromJSON <=< E.nonempty) "LSP_GRPC_CLIENT_ENV" opts

opts :: E.Mod E.Var a
opts =
  E.keep <> E.help ""

withEnv ::
  RawConfig ->
  (Env -> KatipContextT IO a) ->
  IO a
withEnv rc this = do
  pubKeyVar <- newEmptyMVar
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
            "BtcLsp"
            ( Environment $ rawConfigLogEnv rc
            )
  let newSqlPool :: IO (Pool Psql.SqlBackend) =
        runNoLoggingT $
          Psql.createPostgresqlPool (rawConfigLibpqConnStr rc) 10
  let katipCtx = mempty :: LogContexts
  let katipNs = mempty :: Namespace
  let lnd = rawConfigLndEnv rc
  bracket newLogEnv rmLogEnv $ \le ->
    bracket newSqlPool rmSqlPool $ \pool -> do
      let rBtc = rawConfigBtcEnv rc
      btc <-
        Btc.getClient
          (from $ bitcoindEnvHost rBtc)
          (from $ bitcoindEnvUsername rBtc)
          (from $ bitcoindEnvPassword rBtc)
      runKatipContextT le katipCtx katipNs
        . withUnliftIO
        $ \(UnliftIO run) ->
          run . this $
            Env
              { -- General
                envSQLPool = pool,
                -- Logging
                envKatipLE = le,
                envKatipCTX = katipCtx,
                envKatipNS = katipNs,
                -- Lnd
                envLnd = lnd,
                envLndP2PHost = rawConfigLndP2PHost rc,
                envLndP2PPort = rawConfigLndP2PPort rc,
                envSwapIntoLnMinAmt =
                  Math.newSwapIntoLnMinAmt $
                    rawConfigMinChanCap rc,
                envMsatPerByte = rawConfigMsatPerByte rc,
                envLndPubKey = pubKeyVar,
                -- Grpc
                envGrpcServer =
                  (rawConfigGrpcServerEnv rc)
                    { gsEnvSigner = run . signT lnd,
                      gsEnvLogger = run . $(logTM) DebugS . logStr
                    },
                envElectrs = rawConfigElectrsEnv rc,
                envBtc = btc
              }
  where
    rmLogEnv :: LogEnv -> IO ()
    rmLogEnv = void . liftIO . closeScribes
    rmSqlPool :: Pool a -> IO ()
    rmSqlPool = liftIO . destroyAllResources
    signT ::
      Lnd.LndEnv ->
      ByteString ->
      KatipContextT IO (Maybe ByteString)
    signT lnd msg = do
      eSig <-
        Lnd.signMessage lnd $
          Lnd.SignMessageRequest
            { Lnd.message = msg,
              Lnd.keyLoc =
                Lnd.KeyLocator
                  { Lnd.keyFamily = 6,
                    Lnd.keyIndex = 0
                  },
              Lnd.doubleHash = False,
              Lnd.compactSig = False
            }
      case eSig of
        Left e -> do
          $(logTM) ErrorS . logStr $
            "Server ==> signing procedure failed "
              <> inspect e
          pure Nothing
        Right sig0 -> do
          let sig = coerce sig0
          $(logTM) DebugS . logStr $
            "Server ==> signing procedure succeeded for msg of "
              <> inspect (BS.length msg)
              <> " bytes "
              <> inspect msg
              <> " got signature of "
              <> inspect (BS.length sig)
              <> " bytes "
              <> inspect sig
          pure $ Just sig
