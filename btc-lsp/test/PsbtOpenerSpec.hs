{-# LANGUAGE TemplateHaskell #-}

module PsbtOpenerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Psbt.PsbtOpener as PO
import BtcLsp.Psbt.Utils (swapUtxoToPsbtUtxo)
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import Control.Concurrent.Extra
import qualified LndClient.Data.Channel as CH
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.Data.ListChannels as ListChannels
import qualified LndClient.Data.ListLeases as LL
import qualified LndClient.Data.ListUnspent as LU
import qualified LndClient.Data.NewAddress as Lnd
import qualified LndClient.Data.SendCoins as SendCoins
import LndClient.LndTest (mine)
import qualified LndClient.RPC.Silent as Lnd
import Test.Hspec
import TestAppM
import TestHelpers
import TestOrphan ()
import qualified UnliftIO.STM as T

sendAmt :: Env m => Text -> MSat -> ExceptT Failure m ()
sendAmt addr amt =
  void $
    withLndT
      Lnd.sendCoins
      ($ SendCoins.SendCoinsRequest {SendCoins.addr = addr, SendCoins.amount = amt, SendCoins.sendAll = False})

lspFee :: MSat
lspFee = MSat 20000 * 1000

spec :: Spec
spec = do
  itEnvT "PsbtOpener Spec" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap Nothing
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    void BlockScanner.scan
    $(logTM) DebugS $ logStr $ "Expected remote balance:" <> inspect (coerce (20 * amt) - lspFee)
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    void $ lift $ runSql $ SwapUtxo.updateRefundedSql (entityKey <$> utxos) (TxId "dummy refund tx")
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    profitAddr <- genAddress LndLsp
    Lnd.GetInfoResponse alicePubKey _ _ <- withLndTestT LndAlice Lnd.getInfo id
    lock <- liftIO newLock
    openChanRes <- PO.openChannelPsbt lock psbtUtxos alicePubKey (unsafeNewOnChainAddress $ Lnd.address profitAddr) (coerce lspFee) Public
    void . lift . spawnLink $ do
      sleep1s
      mine 1 LndLsp
    chanEither <- liftIO $ wait $ PO.fundAsync openChanRes
    chan <- except chanEither
    $(logTM) DebugS $ logStr $ "Channel is opened:" <> inspect chan
    chnls <-
      withLndT
        Lnd.listChannels
        ( $
            ListChannels.ListChannelsRequest
              { ListChannels.activeOnly = True,
                ListChannels.inactiveOnly = False,
                ListChannels.publicOnly = False,
                ListChannels.privateOnly = False,
                ListChannels.peer = Nothing
              }
        )
    $(logTM) DebugS $ logStr $ "Channel is opened:" <> inspect chnls
    let (openedChanMaybe :: Maybe CH.Channel) = find (\c -> CH.channelPoint c == chan) chnls
    let (expectedRemoteBalance :: MSat) = coerce (20 * amt) - lspFee
    case openedChanMaybe of
      Just c -> do
        liftIO $ do
          shouldBe expectedRemoteBalance (CH.remoteBalance c)
      Nothing -> throwE . FailureInt $ FailurePrivate "Failed to open channel with psbt"

  itEnvT "PsbtOpener subscription exception" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap Nothing
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    void BlockScanner.scan
    $(logTM) DebugS $ logStr $ "Expected remote balance:" <> inspect (coerce (20 * amt) - lspFee)
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    void $ lift $ runSql $ SwapUtxo.updateRefundedSql (entityKey <$> utxos) (TxId "dummy refund tx")
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    profitAddr <- genAddress LndLsp
    Lnd.GetInfoResponse alicePubKey _ _ <- withLndTestT LndAlice Lnd.getInfo id
    lock <- liftIO newLock
    openChanRes <-
      PO.openChannelPsbt lock psbtUtxos alicePubKey (unsafeNewOnChainAddress $ Lnd.address profitAddr) (coerce lspFee) Public
    void . lift . spawnLink $ do
      sleep1s
      mine 1 LndLsp
    void . T.atomically . T.writeTChan (PO.tchan openChanRes) $ PO.LndSubFail
    chanEither <- liftIO $ wait $ PO.fundAsync openChanRes
    $(logTM) ErrorS $ logStr $ "Fails with:" <> inspect chanEither
    leases <- withLndT Lnd.listLeases ($ LL.ListLeasesRequest) <&> LL.lockedUtxos
    let allLockedAfterFail = all (\pu -> isJust $ find (\l -> LL.outpoint l == Just (getOutPoint pu)) leases) psbtUtxos
    liftIO $ do
      shouldSatisfy chanEither isLeft
      shouldBe allLockedAfterFail True

  itEnvT "PsbtOpener multiple channels with one utxo and zeroconfs" $ do
    lift $ mine 4 LndLsp
    lift $ mine 104 LndAlice

    profitAddr <- genAddress LndLsp
    alicePubKey <- getPubKeyT LndAlice
    psbtFlowLock <- liftIO newLock

    swp0 <- createDummySwap Nothing
    let swp0Id = entityKey swp0
    let swp0Addr = swapIntoLnFundAddress . entityVal $ swp0

    swp1 <- createDummySwap Nothing
    let swp1Id = entityKey swp1
    let swp1Addr = swapIntoLnFundAddress . entityVal $ swp1

    let amt = MSat (50000 * 1000)
    void $ transferCoinsToAddr amt LndAlice (from swp0Addr)
    void $ transferCoinsToAddr amt LndAlice (from swp1Addr)

    void putLatestBlockToDB

    lift $ mine 1 LndAlice
    void BlockScanner.scan

    void $ transferAllCoins LndLsp LndAlice

    lift $ mine 2 LndAlice
    void $ transferCoins (4 * amt) LndAlice LndLsp

    allUtxos <- LU.utxos <$> withLndT Lnd.listUnspent ($ LU.ListUnspentRequest 0 maxBound "")
    liftIO $ shouldBe (length allUtxos) 1

    utxos0 <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swp0Id
    void $ lift $ runSql $ SwapUtxo.updateRefundedSql (entityKey <$> utxos0) (TxId "dummy refund tx")
    let psbtUtxos0 = swapUtxoToPsbtUtxo . entityVal <$> utxos0

    openChanRes0 <- PO.openChannelPsbt psbtFlowLock psbtUtxos0 alicePubKey (unsafeNewOnChainAddress $ Lnd.address profitAddr) (coerce lspFee) Public

    utxos1 <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swp1Id
    void $ lift $ runSql $ SwapUtxo.updateRefundedSql (entityKey <$> utxos1) (TxId "dummy refund tx")
    let psbtUtxos1 = swapUtxoToPsbtUtxo . entityVal <$> utxos1

    openChanRes1 <- PO.openChannelPsbt psbtFlowLock psbtUtxos1 alicePubKey (unsafeNewOnChainAddress $ Lnd.address profitAddr) (coerce lspFee) Public

    sleep5s

    void . lift . spawnLink $
      forever $ do
        mine 1 LndAlice
        sleep1s

    (chanEither0, chanEither1) <- liftIO $ waitBoth (PO.fundAsync openChanRes0) (PO.fundAsync openChanRes1)
    liftIO $ do
      shouldSatisfy chanEither0 isRight
      shouldSatisfy chanEither1 isRight
