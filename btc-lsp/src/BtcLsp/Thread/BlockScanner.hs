{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scan,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Rpc.ElectrsRpc as Rpc
import qualified BtcLsp.Rpc.Helper as Rpc
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified Data.Map as M
import qualified Data.Set as S
import qualified Data.Vector as V
import qualified Network.Bitcoin as Btc

apply :: (Env m) => m ()
apply = do
  res <- runExceptT $ scan swapsOnly
  whenLeft res $
    $(logTM) ErrorS . logStr . inspect
  whenRight res (mapM_ markInDb . M.toList)
  sleep $ MicroSecondsDelay 1000000
  apply

markInDb :: (Env m) => (Btc.Address, MSat) -> m ()
markInDb (addr, amt) = do
  $(logTM) DebugS . logStr $ debugMsg
  when isEnough
    . void
    $ SwapIntoLn.updateFunded
      (from addr)
      (from amt)
      lspCap
      lspFee
  where
    isEnough = amt >= from swapLnMinAmt
    lspCap = newChanCapLsp $ from amt
    lspFee = newSwapIntoLnFee $ from amt
    debugMsg =
      "Marking funded "
        <> inspect isEnough
        <> " at addr: "
        <> inspect addr
        <> " with amt: "
        <> inspect amt

askElectrs ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  Set Btc.Address ->
  ExceptT Failure m (Map Btc.Address MSat)
askElectrs cond addrs = do
  --
  -- TODO : maybe optimize with bulk select
  --
  swapAddrs <- filterM cond $ S.toList addrs
  balances <- mapM askConfBalance swapAddrs
  pure $ M.fromList balances
  where
    askConfBalance addr = do
      cb <-
        Rpc.confirmed
          <$> withElectrsT
            Rpc.getBalance
            ($ Left $ OnChainAddress addr)
      pure (addr, cb)

getBlockAddresses :: Btc.BlockVerbose -> Set Btc.Address
getBlockAddresses blk = do
  S.unions
    . V.map extractAddr
    . V.map Btc.scriptPubKey
    . V.foldMap Btc.decVout
    $ Btc.vSubTransactions blk
  where
    extractAddr :: Btc.ScriptPubKey -> Set Btc.Address
    extractAddr (Btc.StandardScriptPubKey _ _ _ _ addrs) =
      V.foldr S.insert S.empty addrs
    extractAddr Btc.NonStandardScriptPubKey {} =
      S.empty

scan ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  ExceptT Failure m (Map Btc.Address MSat)
scan cond = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  natH <- tryFromT cHeight
  void $ Rpc.waitTillLastBlockProcessedT natH
  case mBlk of
    Nothing ->
      scanOneBlock cond cHeight
    Just lBlk -> do
      let s = from . blockHeight $ entityVal lBlk
      let e = from cHeight
      step M.empty (1 + s) e
  where
    step acc cur end = do
      if cur > end
        then pure acc
        else do
          addrs <- scanOneBlock cond $ BlkHeight cur
          step (acc <> addrs) (cur + 1) end

scanOneBlock ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  BlkHeight ->
  ExceptT Failure m (Map Btc.Address MSat)
scanOneBlock cond height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  prevHash <-
    ExceptT . pure $
      maybeToRight
        (FailureInternal "gen block")
        (Btc.vPrevBlock blk)
  balances <- askElectrs cond $ getBlockAddresses blk
  $(logTM) DebugS . logStr $ debugMsg height balances
  lift . void $
    Block.createUpdate height (from hash) (from prevHash)
  pure balances
  where
    debugMsg :: BlkHeight -> Map Btc.Address MSat -> Text
    debugMsg h ma =
      "Scanning block at height: "
        <> inspect h
        <> " found: "
        <> inspect (M.toList ma)

swapsOnly :: (Env m) => Btc.Address -> ExceptT Failure m Bool
swapsOnly =
  (isJust <$>)
    . lift
    . SwapIntoLn.getByFundAddress
    . from
