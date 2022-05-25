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
        >>= mapM_ updateExpiredSwapSql . sort
    --
    -- NOTE : We need to always sort id list before working
    -- with the row locks to avoid possible deadlocks.
    --
    sleep (MicroSecondsDelay 1000000)

updateExpiredSwapSql ::
  ( KatipContext m
  ) =>
  SwapIntoLnId ->
  ReaderT Psql.SqlBackend m ()
updateExpiredSwapSql swapKey = do
  SwapIntoLn.withLockedExtantRowSql swapKey . const $ do
    SwapIntoLn.updateExpiredSql swapKey
