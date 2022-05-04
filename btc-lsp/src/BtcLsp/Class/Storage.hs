module BtcLsp.Class.Storage
  ( Storage (..),
    HasTable (..),
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql

class MonadUnliftIO m => Storage m where
  runSql :: ReaderT Psql.SqlBackend m a -> m a
  getSqlPool :: m (Pool Psql.SqlBackend)

class HasTable a where
  getTable :: Psql.Key a -> Table
