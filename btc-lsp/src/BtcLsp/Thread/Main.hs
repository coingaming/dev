{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.Main
  ( main,
    apply,
    waitForSync,
  )
where

import BtcLsp.Data.AppM (runApp)
import qualified BtcLsp.Data.Env as Env
import BtcLsp.Import
import qualified BtcLsp.Rpc.Env as Btc
import qualified BtcLsp.Storage.Migration as Storage
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified BtcLsp.Thread.Expirer as Expirer
import qualified BtcLsp.Thread.LnChanOpener as LnChanOpener
import qualified BtcLsp.Thread.LnChanWatcher as LnChanWatcher
import qualified BtcLsp.Thread.Refunder as Refunder
import qualified BtcLsp.Thread.Server as Server
import qualified BtcLsp.Yesod.Application as Yesod
import Katip
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin.BlockChain as Btc

main :: IO ()
main = do
  startupScribe <-
    mkHandleScribe ColorIfTerminal stdout (permitItem InfoS) V2
  let startupLogEnv =
        registerScribe
          "stdout"
          startupScribe
          defaultScribeSettings
          =<< initLogEnv "BtcLsp" "startup"
  cfg <- bracket startupLogEnv closeScribes $ \le ->
    runKatipContextT le (mempty :: LogContexts) mempty $ do
      $(logTM) InfoS "Lsp is starting!"
      $(logTM) InfoS "Reading lsp raw environment..."
      cfg <- liftIO readRawConfig
      let secret title x =
            logStr $
              title
                <> " = "
                <> inspect
                  ( SecretLog (Env.rawConfigLogSecrets cfg) x
                  )
      let btc = Env.rawConfigBtcEnv cfg
      $(logTM) InfoS $
        secret
          "rawConfigBtcEnv"
          [ ("host" :: Text, Btc.bitcoindEnvHost btc),
            ("user", Btc.bitcoindEnvUsername btc),
            ("pass", Btc.bitcoindEnvPassword btc)
          ]
      $(logTM) InfoS "Creating lsp runtime environment..."
      pure cfg
  withEnv cfg $
    \env -> runApp env apply

apply :: (Env m) => m ()
apply = do
  $(logTM) InfoS "Waiting for bitcoind..."
  waitForBitcoindSync
  $(logTM) InfoS "Waiting for lnd unlock..."
  unlocked <- withLnd Lnd.lazyUnlockWallet id
  if isRight unlocked
    then do
      $(logTM) InfoS "Waiting for lnd sync..."
      waitForLndSync
      $(logTM) InfoS "Running postgres migrations..."
      Storage.migrateAll
      log <- getYesodLog
      pool <- getSqlPool
      $(logTM) InfoS "Spawning lsp threads..."
      xs <-
        mapM
          spawnLink
          [ Server.apply,
            LnChanWatcher.applySub,
            LnChanWatcher.applyPoll,
            LnChanOpener.apply,
            BlockScanner.apply,
            Refunder.apply,
            Expirer.apply,
            withUnliftIO $ Yesod.appMain log pool
          ]
      $(logTM) InfoS "Lsp is running!"
      liftIO
        . void
        $ waitAnyCancel xs
    else
      $(logTM) ErrorS . logStr $
        "Can not unlock wallet, got "
          <> inspect unlocked
  $(logTM) ErrorS "Lsp terminates!"

waitForBitcoindSync :: (Env m) => m ()
waitForBitcoindSync =
  eitherM
    ( \e -> do
        $(logTM) ErrorS . logStr $ inspect e
        waitAndRetry
    )
    ( \x ->
        when (Btc.bciInitialBlockDownload x) $ do
          $(logTM) InfoS . logStr $ "Waiting IBD: " <> inspect x
          waitAndRetry
    )
    $ withBtc Btc.getBlockChainInfo id
  where
    waitAndRetry :: (Env m) => m ()
    waitAndRetry =
      sleep5s >> waitForBitcoindSync

waitForLndSync :: (Env m) => m ()
waitForLndSync =
  eitherM
    ( \e -> do
        $(logTM) ErrorS . logStr $ inspect e
        waitAndRetry
    )
    ( \x ->
        unless (Lnd.syncedToChain x) $ do
          $(logTM) InfoS . logStr $ "Waiting Lnd: " <> inspect x
          waitAndRetry
    )
    $ withLnd Lnd.getInfo id
  where
    waitAndRetry :: (Env m) => m ()
    waitAndRetry =
      sleep5s >> waitForLndSync

waitForSync :: (Env m) => m ()
waitForSync =
  waitForBitcoindSync
    >> waitForLndSync
