{-# LANGUAGE DeriveFunctor #-}

module BtcLsp.Data.AppM
  ( runApp,
    AppM (..),
  )
where

import BtcLsp.Data.Env as Env (Env (..))
import BtcLsp.Import as I
import qualified BtcLsp.Import.Psql as Psql

newtype AppM m a = AppM
  { unAppM :: ReaderT Env.Env m a
  }
  deriving stock (Functor)
  deriving newtype
    ( Applicative,
      Monad,
      MonadIO,
      MonadReader Env.Env,
      MonadUnliftIO
    )

runApp :: Env.Env -> AppM m a -> m a
runApp env app = runReaderT (unAppM app) env

instance (MonadIO m) => Katip (AppM m) where
  getLogEnv = asks envKatipLE
  localLogEnv f (AppM m) =
    AppM (local (\s -> s {envKatipLE = f (envKatipLE s)}) m)

instance (MonadIO m) => KatipContext (AppM m) where
  getKatipContext = asks envKatipCTX
  localKatipContext f (AppM m) =
    AppM (local (\s -> s {envKatipCTX = f (envKatipCTX s)}) m)
  getKatipNamespace = asks envKatipNS
  localKatipNamespace f (AppM m) =
    AppM (local (\s -> s {envKatipNS = f (envKatipNS s)}) m)

instance (MonadUnliftIO m) => I.Env (AppM m) where
  getGsEnv =
    asks Env.envGrpcServer
  getSwapIntoLnMinAmt =
    asks Env.envSwapIntoLnMinAmt
  getMsatPerByte =
    asks Env.envMsatPerByte
  getLspPubKeyVar =
    asks Env.envLndPubKey
  getLspLndEnv =
    asks Env.envLnd
  getChanPrivacy =
    asks Env.envChanPrivacy
  getLndP2PSocketAddress = do
    host <- asks Env.envLndP2PHost
    port <- asks Env.envLndP2PPort
    pure
      SocketAddress
        { socketAddressHost = host,
          socketAddressPort = port
        }
  withLnd method args = do
    lnd <- asks Env.envLnd
    first FailureLnd <$> args (method lnd)
  withElectrs method args =
    maybeM
      (error "Electrs Env is missing")
      ((first FailureElectrs <$>) . args . method)
      $ asks Env.envElectrs
  withBtc method args = do
    env <- asks Env.envBtc
    --
    -- TODO : catch exceptions!!!
    --
    liftIO $ Right <$> args (method env)

instance (MonadUnliftIO m) => Storage (AppM m) where
  getSqlPool = asks envSQLPool
  runSql query = do
    pool <- asks envSQLPool
    Psql.runSqlPool query pool
