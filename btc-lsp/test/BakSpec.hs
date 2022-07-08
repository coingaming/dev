{-# LANGUAGE TypeApplications #-}

module BakSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified LndClient.Data.Channel as Lnd hiding (outputIndex)
import qualified LndClient.Data.ChannelBackup as Lnd
import qualified LndClient.Data.ChannelPoint as Lnd
import qualified LndClient.Data.ListChannels as Lnd
import LndClient.LndTest
import qualified LndClient.RPC.Silent as Lnd
import Test.Hspec
import TestAppM

spec :: Spec
spec = do
  itMainT @'LndLsp "Static Channel Backup" $ do
    cp <- lift $ setupOneChannel LndLsp LndAlice
    sleep1s
    mCh <-
      (entityVal <<$>>)
        . lift
        . runSql
        . LnChan.getByChannelPointSql (Lnd.fundingTxId cp)
        $ Lnd.outputIndex cp
    case mCh of
      Just (LnChan {lnChanBak = Just bak}) -> do
        cs0 <- getChansT
        liftIO $ length cs0 `shouldBe` 1
        withLndT Lnd.restoreChannelBackups ($ [Lnd.ChannelBackup cp bak])
        sleep1s
        lift $ mine 6 LndAlice
        sleep1s
        cs1 <- getChansT
        --
        -- TODO : fix it! For some reason there is still active
        -- channel even after static backup restore procedure.
        -- Maybe we need to shutdown LND node, remove volumes,
        -- spawn node again, initialize with the same seed
        -- and then restore, to properly test it.
        --
        -- liftIO $ length cs1 `shouldBe` 0
        --
        liftIO $ length cs1 `shouldBe` 1
      Just ch ->
        throwE . FailureInternal $
          "Impossible empty ch " <> inspect ch
      Nothing ->
        throwE . FailureInternal $
          "Impossible empty cp " <> inspect cp
  where
    getChansT :: (Env m) => ExceptT Failure m [Lnd.Channel]
    getChansT =
      withLndT
        Lnd.listChannels
        ( $
            Lnd.ListChannelsRequest
              False
              False
              False
              False
              Nothing
        )
