{-# LANGUAGE TemplateHaskell #-}

module Lsp.Storage
  ( migrateAll,
  )
where

import qualified Database.Persist.Migration as PsqlMig
import qualified Database.Persist.Migration.Postgres as PsqlMig
import Lsp.Import
import qualified Lsp.Import.Psql as Psql

migrateBefore :: PsqlMig.Migration
migrateBefore = []

--
-- TODO : add all needed indexes
--
migrateAfter :: PsqlMig.Migration
migrateAfter =
  [ 0 PsqlMig.~> 1 PsqlMig.:= [lnInvoiceSearchIndexes]
  ]
  where
    lnInvoiceSearchIndexesSql :: Text
    lnInvoiceSearchIndexesSql =
      "CREATE INDEX IF NOT EXISTS "
        <> "merchant_external_payment_expires_at_idx "
        <> "ON merchant_external_payment (expires_at);"
    lnInvoiceSearchIndexes =
      PsqlMig.RawOperation "Create LnInvoiceIn search indexes" $
        lift . return $
          [PsqlMig.MigrateSql lnInvoiceSearchIndexesSql []]

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
