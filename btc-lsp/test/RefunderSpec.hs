{-# LANGUAGE TypeApplications #-}

module RefunderSpec
  ( spec,
  )
where

import BtcLsp.Import
mport qualified Network.Bitcoin as Btc
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp

spec :: Spec
spec = do
  itEnv "Refunder Spec" $ do
    sleep $ MicroSecondsDelay 500000
    mine 100 LndLsp
    res <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      pure True
    liftIO $ shouldBe res (Right True)

