{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage
  ( migrateAll,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified Database.Persist.Migration as PsqlMig
import qualified Database.Persist.Migration.Postgres as PsqlMig

migrateBefore :: PsqlMig.Migration
migrateBefore = []

--
-- TODO : add all needed indexes
--
migrateAfter :: PsqlMig.Migration
migrateAfter =
  [ 0 PsqlMig.~> 1 PsqlMig.:= [lnChannelSearchIndexes]
  ]
  where
    lnChannelSearchIndexesSql :: Text
    lnChannelSearchIndexesSql =
      "CREATE INDEX IF NOT EXISTS "
        <> "ln_channel_status_idx "
        <> "ON ln_channel (status);"
    lnChannelSearchIndexes =
      PsqlMig.RawOperation "Create LnChannel search indexes" $
        lift . return $
          [PsqlMig.MigrateSql lnChannelSearchIndexesSql []]

migrateAll :: (Storage m, KatipContext m) => m ()
migrateAll = do
  $(logTM) InfoS "Running Persistent BEFORE migrations..."
  runM migrateBefore
  $(logTM) InfoS "Running Persistent AUTO migrations..."
  runSql (Psql.runMigration migrateAuto)
  $(logTM) InfoS "Running Persistent AFTER migrations..."
  runM migrateAfter
  $(logTM) InfoS "Persistent database migrated!"
  where
    runM [] = return ()
    runM x = do
      pool <- getSqlPool
      liftIO $
        Psql.runSqlPool
          (PsqlMig.runMigration PsqlMig.defaultSettings x)
          pool
