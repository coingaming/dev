module BtcLsp.Import.Psql
  ( module X,
    persistEq,
  )
where

import Database.Esqueleto.Legacy as X
  ( BaseBackend,
    Entity (..),
    InnerJoin (..),
    Key,
    LeftOuterJoin (..),
    PersistField (..),
    PersistFieldSql (..),
    PersistValue (..),
    RawSql (..),
    RightOuterJoin (..),
    SqlBackend,
    SqlPersistT,
    SqlType (..),
    ToBackendKey,
    asc,
    deleteKey,
    desc,
    from,
    get,
    getBy,
    in_,
    just,
    limit,
    max_,
    min_,
    nothing,
    on,
    orderBy,
    putMany,
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
  ( now_,
    upsertBy,
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
    createPostgresqlPool,
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
