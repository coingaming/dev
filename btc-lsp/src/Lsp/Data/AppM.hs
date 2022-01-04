{-# LANGUAGE DeriveFunctor #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralisedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies #-}

module Lsp.Data.AppM
  ( runApp,
    AppM (..),
  )
where

import Lsp.Data.Env as Env (Env (..))
import Lsp.Import as I
import qualified Lsp.Import.Psql as Psql

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
  getLndEnv = Env.envLnd <$> ask
  getGsEnv = Env.envGrpcServerEnv <$> ask

instance (MonadUnliftIO m) => Storage (AppM m) where
  getSqlPool = asks envSQLPool
  runSql query = do
    pool <- asks envSQLPool
    Psql.runSqlPool query pool
