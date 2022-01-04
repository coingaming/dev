module Lsp.Class.Env
  ( Env (..),
  )
where

import qualified LndClient as Lnd
import Lsp.Class.Storage
import Lsp.Import.External

class
  ( MonadUnliftIO m,
    KatipContext m,
    Storage m
  ) =>
  Env m
  where
  getLndEnv :: m Lnd.LndEnv
  getGsEnv :: m GSEnv
