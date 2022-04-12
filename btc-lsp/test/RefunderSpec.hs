{-# OPTIONS_GHC -Wno-deprecations #-}


module RefunderSpec
  ( spec,
  )
where

import qualified Network.Bitcoin as Btc
import BtcLsp.Import
import Test.Hspec
import TestOrphan ()
import TestWithLndLsp
import TestHelpers
import BtcLsp.Thread.BlockScanner (trySat2MSat)
import Data.Either.Extra (mapLeft)
import BtcLsp.Storage.Model.SwapIntoLn (updateFundedSql)
import qualified BtcLsp.Thread.BlockScanner as BSC
import qualified BtcLsp.Thread.Refunder as RF
import LndClient.LndTest (mine)

scanner :: Env m => m ()
scanner = BSC.apply [RF.apply]

spec :: Spec
spec =
  itEnv "Refunder Spec" $ do
    _eSwp <- runExceptT $ do
      wbal <- withBtcT Btc.getBalance id
      let amt = wbal / 10
      amtMSat <- except $ mapLeft (const $ FailureInternal "Failed to convert msat to sat") $ trySat2MSat amt
      traceShowM amtMSat
      mCap <- lift $ newSwapCapM (from amtMSat)
      cap <- except $ maybeToRight (FailureInternal "failed to get cap") mCap
      swp <- createDummySwap "one block"
      void $ lift $ runSql $ updateFundedSql (entityKey swp) cap
      trId <-  withBtcT Btc.sendToAddress (\h -> h (from . swapIntoLnFundAddress . entityVal $ swp) amt Nothing Nothing)
      traceShowM trId
      void putLatestBlockToDB
      lift $ mine 4 LndLsp
    withSpawnLink scanner $ const $ do
      mine 2 LndLsp
      sleep $ MicroSecondsDelay 50000000
    liftIO $ shouldBe True True

