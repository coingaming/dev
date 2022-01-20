module BtcLsp.Class.Env
  ( Env (..),
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified LndClient as Lnd

class
  ( MonadUnliftIO m,
    KatipContext m,
    Storage m
  ) =>
  Env m
  where
  getGsEnv :: m GSEnv
  withLnd ::
    (Lnd.LndEnv -> a) ->
    (a -> m (Either Lnd.LndError b)) ->
    m (Either Failure b)
  withLndT ::
    (Lnd.LndEnv -> a) ->
    (a -> m (Either Lnd.LndError b)) ->
    ExceptT Failure m b
  withLndT method =
    ExceptT . withLnd method
