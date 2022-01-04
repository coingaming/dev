module BtcLsp.Class.Storage
  ( Storage (..),
    HasTableName (..),
  )
where

import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql

class MonadUnliftIO m => Storage m where
  runSql :: ReaderT Psql.SqlBackend m a -> m a
  getSqlPool :: m (Pool Psql.SqlBackend)

class HasTableName a where
  getTableName :: Psql.Key a -> TableName
