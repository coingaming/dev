{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scanT,
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
  res <- runExceptT $ scanT swapsOnlyT
  whenLeft res $
    $(logTM) ErrorS . logStr . inspect
  sleep $ MicroSecondsDelay 1000000
  apply

askElectrsT ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  Set Btc.Address ->
  ExceptT Failure m (Map Btc.Address MSat)
askElectrsT cond addrs = do
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

scanT ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  ExceptT Failure m (Map Btc.Address MSat)
scanT cond = do
  mBlk <- lift Block.getLatest
  end <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  natH <- tryFromT end
  Rpc.waitTillLastBlockProcessedT natH
  scanUntilT
    end
    cond
    mempty
    $ maybe end (blockHeight . entityVal) mBlk

scanUntilT ::
  ( Env m
  ) =>
  BlkHeight ->
  (Btc.Address -> ExceptT Failure m Bool) ->
  Map Btc.Address MSat ->
  BlkHeight ->
  ExceptT Failure m (Map Btc.Address MSat)
scanUntilT end cond acc curr =
  if curr > end
    then pure acc
    else do
      addrs <- scanBlockT cond curr
      scanUntilT end cond (acc <> addrs) $ curr + 1

scanBlockT ::
  ( Env m
  ) =>
  (Btc.Address -> ExceptT Failure m Bool) ->
  BlkHeight ->
  ExceptT Failure m (Map Btc.Address MSat)
scanBlockT cond height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  prevHash <-
    ExceptT . pure $
      maybeToRight
        (FailureInternal "Genesis block")
        (Btc.vPrevBlock blk)
  balances <- askElectrsT cond $ getBlockAddresses blk
  $(logTM) DebugS . logStr $ debugMsg height balances
  lift . mapM_ updateFundedSwap $ M.toList balances
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

updateFundedSwap :: (Env m) => (Btc.Address, MSat) -> m ()
updateFundedSwap (addr, amt) = do
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

swapsOnlyT :: (Env m) => Btc.Address -> ExceptT Failure m Bool
swapsOnlyT =
  (isJust <$>)
    . lift
    . SwapIntoLn.getByFundAddress
    . from
