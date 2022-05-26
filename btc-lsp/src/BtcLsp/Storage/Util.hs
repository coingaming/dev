module BtcLsp.Storage.Util
  ( lockByTable,
    lockByRow,
    cleanDb,
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Data.Kind
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Universum

-- | This ugly fake type is here just to
-- make Haskell type system compatible
-- with weird Postgres semantics
-- for pg_advisory_xact_lock
data VoidSQL
  = VoidSQL

instance Psql.RawSql VoidSQL where
  rawSqlCols _ _ = (1, [])
  rawSqlColCountReason _ = ""
  rawSqlProcessRow [Psql.PersistNull] = Right VoidSQL
  rawSqlProcessRow _ = Left "Unexpected VoidSQL expr"

lockByTable :: (MonadIO m) => Table -> Psql.SqlPersistT m ()
lockByTable x =
  void
    ( Psql.rawSql
        "SELECT pg_advisory_xact_lock(?)"
        [Psql.PersistInt64 $ fromIntegral $ fromEnum x] ::
        (MonadIO m) => Psql.SqlPersistT m [VoidSQL]
    )

lockByRow ::
  ( MonadIO m,
    HasTable a,
    Psql.ToBackendKey Psql.SqlBackend a
  ) =>
  Psql.Key a ->
  Psql.SqlPersistT m a
lockByRow rowId = do
  void
    ( Psql.rawSql
        "SELECT pg_advisory_xact_lock(?,?)"
        [ Psql.PersistInt64 . from . fromEnum $ getTable rowId,
          Psql.PersistInt64 $ Psql.fromSqlKey rowId
        ] ::
        (MonadIO m) => Psql.SqlPersistT m [VoidSQL]
    )
  maybeM
    (error $ "Impossible missing row " <> Universum.show rowId)
    pure
    $ Psql.get rowId

cleanDb :: (MonadIO m) => Psql.SqlPersistT m ()
cleanDb =
  Psql.rawExecute
    ( "DROP SCHEMA IF EXISTS public CASCADE;"
        <> "CREATE SCHEMA public;"
        <> "GRANT ALL ON SCHEMA public TO public;"
        <> "COMMENT ON SCHEMA public IS 'standard public schema';"
    )
    []
