{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Util
  ( lockByTable,
    lockByRow,
    rollback,
    commit,
    cleanDb,
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified BtcLsp.Import.Psql as Psql
import qualified Universum

-- this ugly fake type is here just to
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

lockByTable :: (MonadIO m) => TableName -> Psql.SqlPersistT m ()
lockByTable x =
  void
    ( Psql.rawSql
        "SELECT pg_advisory_xact_lock(?)"
        [Psql.PersistInt64 $ fromIntegral $ fromEnum x] ::
        (MonadIO m) => Psql.SqlPersistT m [VoidSQL]
    )

lockByRow ::
  ( MonadIO m,
    HasTableName a,
    Psql.ToBackendKey Psql.SqlBackend a
  ) =>
  Psql.Key a ->
  Psql.SqlPersistT m (Entity a)
lockByRow rowId = do
  void
    ( Psql.rawSql
        "SELECT pg_advisory_xact_lock(?,?)"
        [ Psql.PersistInt64 $ fromIntegral $ fromEnum $ getTableName rowId,
          Psql.PersistInt64 $ Psql.fromSqlKey rowId
        ] ::
        (MonadIO m) => Psql.SqlPersistT m [VoidSQL]
    )
  maybeM
    (error $ "Impossible missing row " <> Universum.show rowId)
    (pure . Entity rowId)
    $ Psql.get rowId

rollback :: (KatipContext m, Out a) => a -> Psql.SqlPersistT m (Either a b)
rollback e = do
  Psql.transactionUndo
  $(logTM) DebugS . logStr $ "Rollback " <> inspect e
  pure $ Left e

commit :: (KatipContext m, Out b) => b -> Psql.SqlPersistT m (Either a b)
commit x = do
  $(logTM) DebugS . logStr $ "Commit " <> inspect x
  pure $ Right x

cleanDb :: MonadIO m => Psql.SqlPersistT m ()
cleanDb =
  Psql.rawExecute
    ( "DROP SCHEMA IF EXISTS public CASCADE;"
        <> "CREATE SCHEMA public;"
        <> "GRANT ALL ON SCHEMA public TO public;"
        <> "COMMENT ON SCHEMA public IS 'standard public schema';"
    )
    []
