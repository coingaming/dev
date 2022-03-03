{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified Network.Bitcoin as Btc
import qualified Data.Set as S
import qualified Data.Vector as V


apply :: (Env m) => m ()
apply = do
  r <- runExceptT scan
  traceShowM r
  sleep $ MicroSecondsDelay 1000000
  apply


getBlockAddresses :: Btc.BlockVerbose -> Set Btc.Address
getBlockAddresses blk = do
    S.unions $ V.map extractAddr $
      V.map Btc.scriptPubKey $ V.foldMap Btc.decVout $ Btc.vSubTransactions blk
  where
    extractAddr :: Btc.ScriptPubKey -> Set Btc.Address
    extractAddr (Btc.StandardScriptPubKey _ _ _ _ addrs) = V.foldr S.insert S.empty addrs
    extractAddr _ = S.empty

heighToInt :: BlkHeight -> Integer
heighToInt (BlkHeight c) = c

scan :: (Env m)
     => ExceptT Failure m (Set Btc.Address)
scan = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  case mBlk of
    Nothing -> scanOneBlock cHeight
    Just lBlk -> do
      let s = heighToInt $ blockHeight $ entityVal lBlk
      step S.empty (1 + s) (heighToInt cHeight)
    where
      step acc cur end = do
        if cur == end
           then do
             addrs <- scanOneBlock $ BlkHeight cur
             pure (acc <> addrs)
           else do
             r <- step acc (cur + 1) end
             pure (acc <> r)


scanOneBlock :: (Env m) =>
  BlkHeight -> ExceptT Failure m (Set Btc.Address)
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  traceShowM blk
  prevHash <- ExceptT $ pure $ maybeToRight (FailureInternal "gen block") (Btc.vPrevBlock blk)
  lift . void $ Block.createUpdate height (from hash) (from prevHash)
  let r = getBlockAddresses blk
  traceShowM r
  pure r
