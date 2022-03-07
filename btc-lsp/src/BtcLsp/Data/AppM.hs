{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies #-}

module BtcLsp.Data.AppM
  ( runApp,
    AppM (..),
  )
where

import BtcLsp.Data.Env as Env (Env (..))
import BtcLsp.Import as I
import qualified BtcLsp.Import.Psql as Psql
import qualified LndClient as Lnd
import qualified Network.GRPC.Client.Helpers as Grpc

newtype AppM m a = AppM
  { unAppM :: ReaderT Env.Env m a
  }
  deriving
    ( Functor,
      Applicative,
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
  getLspPubKeyVar =
    asks Env.envLndPubKey
  getLspLndEnv =
    asks Env.envLnd
  getLspLndSocketAddress = do
    env <- Lnd.envLndConfig <$> asks Env.envLnd
    pure
      SocketAddress
        { socketAddressHost = Grpc._grpcClientConfigHost env,
          socketAddressPort = Grpc._grpcClientConfigPort env
        }
  withLnd method args = do
    lnd <- asks Env.envLnd
    first FailureLnd <$> args (method lnd)
  withElectrs method args = do
    env <- asks Env.envElectrs
    first FailureElectrs <$> args (method env)
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
