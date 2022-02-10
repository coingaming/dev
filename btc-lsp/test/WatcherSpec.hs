{-# OPTIONS_GHC -Wno-deprecations #-}
{-# OPTIONS_GHC -Wno-unused-matches #-}

module WatcherSpec
  ( spec,
  )
where

import BtcLsp.Import hiding (takeMVar, putMVar, newEmptyMVar)
import Test.Hspec
import qualified BtcLsp.Thread.Server as Server
import TestWithLndLsp
import LndClient.LndTest
import Control.Concurrent
import BtcLsp.Watcher.ChannelWatcher (watchChannelEvents)


spec :: Spec
spec =
  itEnv "Watch channel" $ do
    withSpawnLink Server.apply . const $ do
      print ("hehe" :: Text)
      lnd <- testLndEnv . testEnvLndLsp <$> ask
      (tid, hndl) <- watchChannelEvents lnd
      liftIO $ takeMVar hndl
      liftIO $ shouldBe True True

