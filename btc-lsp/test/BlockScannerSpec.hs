{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BlockScannerSpec
  ( spec,
  )
where

import BtcLsp.Import
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Thread.Main as Main
import LndClient.LndTest (mine)
import qualified Network.Bitcoin.Wallet as Btc
import Test.Hspec

spec :: Spec
spec = do
  itEnv "Block scanner" $ do
    withSpawnLink Main.apply . const $ do
      sleep $ MicroSecondsDelay 500000
      _r <- runExceptT $
        withBtcT Btc.sendToAddress (\h -> h "bcrt1qxfrzgen4mcru4p23nthqjezf2f50taz6ls4w8x" 1 Nothing Nothing)
      mine 1 LndLsp
      sleep $ MicroSecondsDelay $ 2 * 1000000
      liftIO $ shouldBe True True

