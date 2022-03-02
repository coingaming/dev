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
import qualified LndClient.RPC.Katip as Lnd
import qualified BtcLsp.Thread.LnChanWatcher as LnChanWatcher

main :: IO ()
main = do
  cfg <- readRawConfig
  withEnv cfg $ \env ->
    runApp env apply

apply :: (Env m) => m ()
apply = do
  unlocked <- withLnd Lnd.lazyUnlockWallet id
  if isRight unlocked
    then do
      StorageMigration.migrateAll
      xs <-
        mapM
          spawnLink
          [ ThreadServer.apply,
            LnChanWatcher.apply,
            LnChanWatcher.applyListChannelWatcher
          ]
      liftIO
        . void
        $ waitAnyCancel xs
    else
      $(logTM) ErrorS . logStr $
        "Can not unlock wallet, got " <> inspect unlocked
  $(logTM) ErrorS "Terminate program"
