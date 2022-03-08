{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply, scan
  )
where

import BtcLsp.Import
import qualified BtcLsp.Rpc.ElectrsRpc as Rpc
import qualified BtcLsp.Rpc.Helper as Rpc
import qualified BtcLsp.Storage.Model.Block as Block
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Vector as V
import qualified Network.Bitcoin as Btc
import qualified BtcLsp.Storage.Model.SwapIntoLn as SL

apply :: (Env m) => m ()
apply = do
  res <- runExceptT scan
  whenLeft res $
    $(logTM) ErrorS . logStr . inspect
  whenRight res (mapM_ markInDb . M.toList)
  sleep $ MicroSecondsDelay 1000000
  apply


markInDb :: (Env m) => (Btc.Address, MSat) -> m ()
markInDb (addr, amt) = do
  $(logTM) DebugS . logStr $ debugMsg
  when isEnought (void $ SL.updateFunded (from addr) (from amt) lspCap lspFee)
  where
    isEnought = amt >= from swapLnMinAmt
    lspCap = newChanCapLsp $ from amt
    lspFee = newSwapIntoLnFee $ from amt
    debugMsg = "Marking funded ()" <>
      inspect isEnought <> " at addr: " <> inspect addr <> " with amt: " <> inspect amt


askElectrs :: (Env m) => Set Btc.Address -> ExceptT Failure m (Map Btc.Address MSat)
askElectrs addrs = do
  ab <- mapM askConfBalance (S.toList addrs)
  pure $ M.fromList ab
  where
    askConfBalance addr = do
      cb <- Rpc.confirmed <$> withElectrsT Rpc.getBalance ($ Left $ OnChainAddress addr)
      pure (addr, cb)

getBlockAddresses :: Btc.BlockVerbose -> Set Btc.Address
getBlockAddresses blk = do
  S.unions $
    V.map extractAddr $
      V.map Btc.scriptPubKey $ V.foldMap Btc.decVout $ Btc.vSubTransactions blk
  where
    extractAddr :: Btc.ScriptPubKey -> Set Btc.Address
    extractAddr (Btc.StandardScriptPubKey _ _ _ _ addrs) = V.foldr S.insert S.empty addrs
    extractAddr Btc.NonStandardScriptPubKey {} = S.empty

scan ::
  (Env m) =>
  ExceptT Failure m (Map Btc.Address MSat)
scan = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  void $ Rpc.waitTillLastBlockProcessedT $ from cHeight
  case mBlk of
    Nothing -> scanOneBlock cHeight
    Just lBlk -> do
      let s = from $ blockHeight $ entityVal lBlk
      let e = from cHeight
      step M.empty (1 + s) e
  where
    step acc cur end = do
      if cur > end
        then pure acc
        else do
          addrs <- scanOneBlock $ BlkHeight cur
          step (acc <> addrs) (cur + 1) end

scanOneBlock ::
  (Env m) =>
  BlkHeight ->
  ExceptT Failure m (Map Btc.Address MSat)
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  prevHash <- ExceptT $ pure $ maybeToRight (FailureInternal "gen block") (Btc.vPrevBlock blk)
  r <- askElectrs $ getBlockAddresses blk
  lift $ $(logTM) DebugS . logStr $ debugMsg height r
  lift . void $ Block.createUpdate height (from hash) (from prevHash)
  pure r
  where
    debugMsg :: BlkHeight -> Map Btc.Address MSat -> Text
    debugMsg h ma = "Scanning block at h: " <> inspect h <> " found: " <> inspect (M.toList ma)

