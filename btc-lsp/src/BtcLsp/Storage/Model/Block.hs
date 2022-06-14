module BtcLsp.Storage.Model.Block
  ( createUpdateConfirmedSql,
    getLatestSql,
    getBlockByHeightSql,
    getBlocksHigherSql,
    updateOrphanHigherSql,
    withLockedRowSql,
  )
where

import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Util as Util

createUpdateConfirmedSql ::
  ( MonadIO m
  ) =>
  BlkHeight ->
  BlkHash ->
  ReaderT Psql.SqlBackend m (Entity Block)
createUpdateConfirmedSql height hash = do
  ct <- getCurrentTime
  Psql.upsertBy
    (UniqueBlock hash)
    Block
      { blockHeight = height,
        blockHash = hash,
        blockStatus = BlkConfirmed,
        blockInsertedAt = ct,
        blockUpdatedAt = ct
      }
    [ BlockStatus Psql.=. Psql.val BlkConfirmed,
      BlockUpdatedAt Psql.=. Psql.val ct
    ]

getLatestSql ::
  ( MonadIO m
  ) =>
  ReaderT Psql.SqlBackend m (Maybe (Entity Block))
getLatestSql = do
  xs <- Psql.select $
    Psql.from $ \row -> do
      Psql.locking Psql.ForUpdate
      Psql.where_ $
        row Psql.^. BlockStatus
          Psql.==. Psql.val BlkConfirmed
      Psql.orderBy
        [ Psql.desc $
            row Psql.^. BlockHeight
        ]
      Psql.limit 1
      pure row
  pure $
    listToMaybe xs

getBlockByHeightSql ::
  ( MonadIO m
  ) =>
  BlkHeight ->
  ReaderT Psql.SqlBackend m [Entity Block]
getBlockByHeightSql blkHeight = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.locking Psql.ForUpdate
      Psql.where_ $
        ( row Psql.^. BlockHeight
            Psql.==. Psql.val blkHeight
        )
          Psql.&&. ( row Psql.^. BlockStatus
                       Psql.==. Psql.val BlkConfirmed
                   )
      pure row

getBlocksHigherSql ::
  ( MonadIO m
  ) =>
  BlkHeight ->
  ReaderT Psql.SqlBackend m [Entity Block]
getBlocksHigherSql blkHeight = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.locking Psql.ForUpdate
      Psql.where_ $
        ( row Psql.^. BlockHeight
            Psql.>. Psql.val blkHeight
        )
          Psql.&&. ( row Psql.^. BlockStatus
                       Psql.==. Psql.val BlkConfirmed
                   )
      pure row

updateOrphanHigherSql ::
  ( MonadIO m
  ) =>
  BlkHeight ->
  ReaderT Psql.SqlBackend m ()
updateOrphanHigherSql height = do
  ct <- getCurrentTime
  Psql.update $ \row -> do
    Psql.set
      row
      [ BlockStatus Psql.=. Psql.val BlkOrphan,
        BlockUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. BlockHeight
          Psql.>. Psql.val height
      )
        Psql.&&. ( row Psql.^. BlockStatus
                     Psql.==. Psql.val BlkConfirmed
                 )

withLockedRowSql ::
  ( MonadIO m
  ) =>
  BlockId ->
  (BlkStatus -> Bool) ->
  (Block -> ReaderT Psql.SqlBackend m a) ->
  ReaderT Psql.SqlBackend m (Either (Entity Block) a)
withLockedRowSql rowId pre action = do
  rowVal <- Util.lockByRow rowId
  if pre $ blockStatus rowVal
    then Right <$> action rowVal
    else pure . Left $ Entity rowId rowVal
