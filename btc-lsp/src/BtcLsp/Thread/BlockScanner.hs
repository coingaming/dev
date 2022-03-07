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

apply :: (Env m) => m ()
apply = do
  _r <- runExceptT scan
  sleep $ MicroSecondsDelay 1000000
  apply

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
    extractAddr _ = S.empty

heighToInt :: BlkHeight -> Integer
heighToInt (BlkHeight c) = c

scan ::
  (Env m) =>
  ExceptT Failure m (Map Btc.Address MSat)
scan = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  void $ Rpc.waitTillLastBlockProcessedT $ heighToInt cHeight
  case mBlk of
    Nothing -> scanOneBlock cHeight
    Just lBlk -> do
      let s = heighToInt $ blockHeight $ entityVal lBlk
      let e = heighToInt cHeight
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
  lift . void $ Block.createUpdate height (from hash) (from prevHash)
  pure r
