{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.Main
  ( main,
    apply,
  )
where

import BtcLsp.Data.AppM (runApp)
import BtcLsp.Import
import qualified BtcLsp.Storage.Migration as StorageMigration
import qualified BtcLsp.Thread.Server as ThreadServer

main :: IO ()
main = do
  cfg <- readRawConfig
  withEnv cfg $ \env ->
    runApp env apply

apply :: (Env m) => m ()
apply = do
  StorageMigration.migrateAll
  xs <-
    mapM
      spawnLink
      [ ThreadServer.apply
      ]
  liftIO
    . void
    $ waitAnyCancel xs
  $(logTM) ErrorS "Terminate program"
