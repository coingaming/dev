{-# LANGUAGE TypeApplications #-}

module ReorgSpec
  ( spec,
  )
where

import Test.Hspec
import TestOrphan ()
import qualified Network.Bitcoin as Btc
import TestWithLndLsp
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Import hiding (setGrpcCtx, setGrpcCtxT)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner

spec :: Spec
spec = focus $ itEnv "Reorg test" $ do
    _ <- runExceptT $ do
      void $ withBtcT Btc.setNetworkActive ($ False)
      void $ withBtc2T Btc.setNetworkActive ($ False)
      c1 <- withBtcT Btc.getBlockCount id
      c2 <- withBtc2T Btc.getBlockCount id
      _ <- BlockScanner.scan




      void $ withBtcT Btc.generate (\h -> h 5 Nothing)
      void $ withBtc2T Btc.generate (\h -> h 10 Nothing)
      c3 <- withBtcT Btc.getBlockCount id
      c4 <- withBtc2T Btc.getBlockCount id
      void $ withBtcT Btc.setNetworkActive ($ True)
      void $ withBtc2T Btc.setNetworkActive ($ True)
      sleep (MicroSecondsDelay 10000000)
      c5 <- withBtcT Btc.getBlockCount id
      c6 <- withBtc2T Btc.getBlockCount id
      print ("==========================" :: Text)
      print c1
      print c2
      print ("==========================" :: Text)
      print c3
      print c4
      print ("==========================" :: Text)
      print c5
      print c6
      print ("==========================" :: Text)
      return ()
    liftIO $ True `shouldBe` True
