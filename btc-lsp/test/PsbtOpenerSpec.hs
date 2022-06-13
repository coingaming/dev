{-# OPTIONS_GHC -Wno-deprecations #-}
{-# LANGUAGE TemplateHaskell #-}
module PsbtOpenerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified LndClient.Data.SendCoins as SendCoins
import qualified LndClient.RPC.Silent as Lnd
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestAppM
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import LndClient.LndTest (mine)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import BtcLsp.Thread.PsbtOpener (openChannelPsbt)
import BtcLsp.Thread.Utils (swapUtxoToPsbtUtxo)
import qualified LndClient.Data.ListChannels as ListChannels
import qualified LndClient.Data.Channel as CH

sendAmt :: Env m => Text -> MSat -> ExceptT Failure m ()
sendAmt addr amt =
  void $ withLndT
    Lnd.sendCoins ($ SendCoins.SendCoinsRequest {SendCoins.addr = addr, SendCoins.amount = amt})

fixedMinerFee :: MSat
fixedMinerFee = MSat $ 500 * 1000

lspFee :: MSat
lspFee = MSat 20000 * 1000

spec :: Spec
spec =
  itEnvT "PsbtOpener Spec" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap Nothing
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    _utxosRaw <- BlockScanner.scan
    $(logTM) DebugS $ logStr $ "Expected remote balance:" <> inspect (coerce (20 * amt) - lspFee - fixedMinerFee)
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    profitAddr <- genAddress LndLsp
    Lnd.GetInfoResponse alicePubKey _ _ <- withLndTestT LndAlice Lnd.getInfo id
    chanOpenAsync <- lift . spawnLink $ do
      runExceptT $ openChannelPsbt psbtUtxos alicePubKey (coerce $ Lnd.address profitAddr) lspFee fixedMinerFee
    _mineAsync <- lift . spawnLink $ do
      sleep1s
      mine 1 LndLsp
    chanEither <- liftIO $ wait chanOpenAsync
    chan <- except chanEither
    $(logTM) DebugS $ logStr $ "Channel is opened:" <> inspect chan
    chnls <- withLndT
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
    let (expectedRemoteBalance :: MSat) = coerce (20 * amt) - lspFee - fixedMinerFee
    case openedChanMaybe of
      Just c -> do
        liftIO $ do
          shouldBe expectedRemoteBalance (CH.remoteBalance c)
      Nothing -> throwE $ FailureInternal "Failed to open channel with psbt"


