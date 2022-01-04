{-# LANGUAGE TemplateHaskell #-}

module Lsp.Thread.Main
  ( main,
    apply,
  )
where

import Lsp.Data.AppM (runApp)
import Lsp.Import
import qualified Lsp.Storage as Storage
import qualified Lsp.Thread.Server as ThreadServer

main :: IO ()
main = do
  cfg <- readRawConfig
  withEnv cfg $ \env ->
    runApp env apply

apply :: (Env m) => m ()
apply = do
  Storage.migrateAll
  xs <-
    mapM
      spawnLink
      [ ThreadServer.apply
      ]
  liftIO
    . void
    $ waitAnyCancel xs
  $(logTM) ErrorS "Terminate program"
