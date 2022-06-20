{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.Expirer
  ( apply,
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn

apply :: (Env m) => m ()
apply =
  forever $ do
    runSql $
      entityKey <<$>> SwapIntoLn.getSwapsAboutToExpirySql
        --
        -- NOTE : We need to always sort id list before working
        -- with the row locks to avoid possible deadlocks.
        --
        >>= mapM_ updateExpiredSwapSql . sort
    sleep300ms

updateExpiredSwapSql ::
  ( KatipContext m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateExpiredSwapSql rowId = do
  res <-
    SwapIntoLn.withLockedRowSql
      rowId
      (`elem` swapStatusChain)
      . const
      $ SwapIntoLn.updateExpiredSql rowId
  whenLeft res $
    $(logTM) ErrorS
      . logStr
      . ("Expiry update failed for the swap " <>)
      . inspect
