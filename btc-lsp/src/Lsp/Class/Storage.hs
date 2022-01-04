module Lsp.Class.Storage
  ( Storage (..),
    HasTableName (..),
  )
where

import Lsp.Data.Type
import Lsp.Import.External
import qualified Lsp.Import.Psql as Psql

class MonadUnliftIO m => Storage m where
  runSql :: ReaderT Psql.SqlBackend m a -> m a
  getSqlPool :: m (Pool Psql.SqlBackend)

class HasTableName a where
  getTableName :: Psql.Key a -> TableName
