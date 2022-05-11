module BtcLsp.Storage.Model.Block
  ( createUpdateSql,
    getLatestSql,
    getBlockByHeightSql,
    getOrphanBlocksHigherSql,
    makeOrphanBlocksHigherSql,
  )
where

import BtcLsp.Import hiding (Storage (..))
import qualified BtcLsp.Import.Psql as Psql

--import qualified Database.Esqueleto as Psql

createUpdateSql ::
  ( MonadIO m
  ) =>
  BlkHeight ->
  BlkHash ->
  Maybe BlkPrevHash ->
  ReaderT Psql.SqlBackend m (Entity Block)
createUpdateSql height hash prev = do
  ct <- getCurrentTime
  --
  -- TODO : investigate how this will behave
  -- in case where multiple instances of scanner
  -- are running (as lsp cluster).
  -- Any possible race conditions?
  --
  -- TODO : this should be replaced with more advanced
  -- reorg logic.
  --
  Psql.update $ \row -> do
    Psql.set
      row
      [ BlockStatus Psql.=. Psql.val BlkOrphan,
        BlockUpdatedAt Psql.=. Psql.val ct
      ]
    Psql.where_ $
      ( row Psql.^. BlockHeight
          Psql.==. Psql.val height
      )
        Psql.&&. ( row Psql.^. BlockStatus
                     Psql.==. Psql.val BlkConfirmed
                 )
        Psql.&&. ( row Psql.^. BlockHash
                     Psql.!=. Psql.val hash
                 )
  Psql.upsertBy
    (UniqueBlock hash)
    Block
      { blockHeight = height,
        blockHash = hash,
        blockPrev = prev,
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
getLatestSql =
  listToMaybe
    <$> Psql.selectList
      [ BlockStatus `Psql.persistEq` BlkConfirmed
      ]
      [ Psql.Desc BlockHeight,
        Psql.LimitTo 1
      ]

getBlockByHeightSql :: (MonadIO m) => BlkHeight -> ReaderT Psql.SqlBackend m [Entity Block]
getBlockByHeightSql blkHeight = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_ $
        (row Psql.^. BlockHeight Psql.==. Psql.val blkHeight)
          Psql.&&. ( row Psql.^. BlockStatus
                       Psql.==. Psql.val BlkConfirmed
                   )
      pure row


getOrphanBlocksHigherSql :: (MonadIO m) => BlkHeight -> ReaderT Psql.SqlBackend m [Entity Block]
getOrphanBlocksHigherSql blkHeight = do
  Psql.select $
    Psql.from $ \row -> do
      Psql.where_ $
        (row Psql.^. BlockHeight Psql.>. Psql.val blkHeight)
          Psql.&&. ( row Psql.^. BlockStatus
                       Psql.==. Psql.val BlkConfirmed
                   )
      pure row

makeOrphanBlocksHigherSql :: (MonadIO m) => BlkHeight -> ReaderT Psql.SqlBackend m ()
makeOrphanBlocksHigherSql height = do
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
