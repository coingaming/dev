{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Storage.Migration
  ( migrateAll,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified Database.Persist.Migration as PsqlMig
import qualified Database.Persist.Migration.Postgres as PsqlMig

migrateBefore :: PsqlMig.Migration
migrateBefore =
  [ 1 PsqlMig.~> 2
      PsqlMig.:= [ dropFundInvHashConstraint,
                   dropFundInvoice,
                   dropFundInvHash,
                   dropFundProof
                 ]
  ]
  where
    dropFundInvHashConstraint =
      PsqlMig.RawOperation "Drop fund_inv_hash unique constraint" $
        lift . return $
          [PsqlMig.MigrateSql "ALTER TABLE IF EXISTS swap_into_ln DROP CONSTRAINT IF EXISTS unique_swap_into_ln_fund_inv_hash" []]
    dropFundInvoice =
      PsqlMig.RawOperation "Drop fund_invoice" $
        lift . return $
          [PsqlMig.MigrateSql "ALTER TABLE IF EXISTS swap_into_ln DROP COLUMN IF EXISTS fund_invoice" []]
    dropFundInvHash =
      PsqlMig.RawOperation "Drop fund_inv_hash" $
        lift . return $
          [PsqlMig.MigrateSql "ALTER TABLE IF EXISTS swap_into_ln DROP COLUMN IF EXISTS fund_inv_hash" []]
    dropFundProof =
      PsqlMig.RawOperation "Drop fund_proof" $
        lift . return $
          [PsqlMig.MigrateSql "ALTER TABLE IF EXISTS swap_into_ln DROP COLUMN IF EXISTS fund_proof" []]

--
-- TODO : add all needed indexes
--
migrateAfter :: PsqlMig.Migration
migrateAfter =
  [ 0 PsqlMig.~> 1 PsqlMig.:= [lnChanSearchIndexes]
  ]
  where
    lnChanSearchIndexesSql :: Text
    lnChanSearchIndexesSql =
      "CREATE INDEX IF NOT EXISTS "
        <> "ln_chan_status_idx "
        <> "ON ln_chan (status);"
    lnChanSearchIndexes =
      PsqlMig.RawOperation "Create LnChan search indexes" $
        lift . return $
          [PsqlMig.MigrateSql lnChanSearchIndexesSql []]

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
