{-# OPTIONS_GHC -Wno-deprecations #-}
{-# LANGUAGE TemplateHaskell #-}
module PsbtOpenerSpec
  ( spec,
  )
where

import BtcLsp.Import
import qualified LndClient as Lnd
import qualified LndClient.Data.SendCoins as SendCoins
import qualified LndClient.RPC.Silent as Lnd
import Test.Hspec
import TestHelpers
import TestOrphan ()
import TestWithLndLsp
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import LndClient.LndTest (mine)
import qualified BtcLsp.Thread.BlockScanner as BlockScanner
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.Data.NewAddress as Lnd
import BtcLsp.Thread.PsbtOpener (openChannelPsbt)
import BtcLsp.Thread.Utils (swapUtxoToPsbtUtxo)

sendAmt :: Env m => Text -> MSat -> ExceptT Failure m ()
sendAmt addr amt =
  void $ withLndT
    Lnd.sendCoins ($ SendCoins.SendCoinsRequest {SendCoins.addr = addr, SendCoins.amount = amt})

fixedMinerFee :: MSat
fixedMinerFee = MSat $ 500 * 1000

spec :: Spec
spec =
  itEnvT "PsbtOpener Spec" $ do
    amt <- lift getSwapIntoLnMinAmt
    swp <- createDummySwap "psbt opener test" . Just =<< getFutureTime (Lnd.Seconds 5)
    let swpId = entityKey swp
    let swpAddr = swapIntoLnFundAddress . entityVal $ swp
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void $ sendAmt (from swpAddr) (from (10 * amt))
    void putLatestBlockToDB
    lift $ mine 4 LndLsp
    _utxosRaw <- BlockScanner.scan
    utxos <- lift $ runSql $ SwapUtxo.getSpendableUtxosBySwapIdSql swpId
    let psbtUtxos = swapUtxoToPsbtUtxo . entityVal <$> utxos
    profitAddr <- genAddress LndLsp
    Lnd.GetInfoResponse alicePubKey _ _ <- withLndTestT LndAlice Lnd.getInfo id
    _r <- openChannelPsbt psbtUtxos alicePubKey (coerce $ Lnd.address profitAddr) (MSat 20000 * 1000) fixedMinerFee
    pure ()



