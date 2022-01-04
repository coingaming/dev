module BtcLsp.Class.Env
  ( Env (..),
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Import.External
import qualified LndClient as Lnd

class
  ( MonadUnliftIO m,
    KatipContext m,
    Storage m
  ) =>
  Env m
  where
  getLndEnv :: m Lnd.LndEnv
  getGsEnv :: m GSEnv
