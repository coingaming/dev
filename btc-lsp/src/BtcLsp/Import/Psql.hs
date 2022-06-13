module BtcLsp.Import.Psql
  ( module X,
    persistEq,
  )
where

import Database.Esqueleto.Legacy as X
  ( BaseBackend,
    Entity (..),
    FullOuterJoin (..),
    InnerJoin (..),
    Key,
    LeftOuterJoin (..),
    LockingKind (..),
    PersistEntity (..),
    PersistField (..),
    PersistFieldSql (..),
    PersistValue (..),
    RawSql (..),
    RightOuterJoin (..),
    SqlBackend,
    SqlPersistT,
    SqlType (..),
    ToBackendKey,
    Unique,
    asc,
    deleteKey,
    desc,
    from,
    get,
    getBy,
    in_,
    just,
    limit,
    locking,
    max_,
    min_,
    notIn,
    nothing,
    on,
    orderBy,
    rawExecute,
    rawSql,
    runMigration,
    runSqlPool,
    select,
    selectFirst,
    set,
    transactionUndo,
    unValue,
    update,
    updateCount,
    val,
    valList,
    where_,
    (!=.),
    (&&.),
    (+=.),
    (<.),
    (=.),
    (==.),
    (>.),
    (>=.),
    (?.),
    (^.),
    (||.),
  )
import Database.Esqueleto.PostgreSQL as X
  ( upsertBy,
  )
import Database.Persist as X
  ( LiteralType (..),
    SelectOpt (..),
    selectList,
  )
import qualified Database.Persist as P
import Database.Persist.Class as X
  ( BackendKey,
  )
import Database.Persist.Postgresql as X
  ( ConnectionString,
    copyField,
    createPostgresqlPool,
    upsertManyWhere,
  )
import Database.Persist.Sql as X
  ( fromSqlKey,
    toSqlKey,
  )
import Database.Persist.TH as X
  ( derivePersistField,
  )

persistEq ::
  forall v typ.
  P.PersistField typ =>
  P.EntityField v typ ->
  typ ->
  P.Filter v
persistEq =
  (P.==.)
