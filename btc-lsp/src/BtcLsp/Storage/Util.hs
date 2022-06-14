module BtcLsp.Storage.Util
  ( lockByTable,
    lockByRow,
    lockByUnique,
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
        [Psql.PersistInt64 . from $ fromEnum x] ::
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
    . (entityVal <<$>>)
    . (listToMaybe <$>)
    $ Psql.select $
      Psql.from $ \row -> do
        Psql.locking Psql.ForUpdate
        Psql.where_
          ( row Psql.^. Psql.persistIdField
              Psql.==. Psql.val rowId
          )
        pure row

lockByUnique ::
  ( MonadIO m,
    HasTable a,
    Psql.ToBackendKey Psql.SqlBackend a
  ) =>
  Psql.Unique a ->
  Psql.SqlPersistT m (Maybe (Entity a))
lockByUnique =
  maybeM
    (pure Nothing)
    (\(Entity x _) -> Just . Entity x <$> lockByRow x)
    . Psql.getBy
