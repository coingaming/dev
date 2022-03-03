{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified Network.Bitcoin as Btc
import qualified Data.Set as S
import qualified Data.Vector as V


-- apply :: (Env m) => m ()
-- apply = do
--   res <- runExceptT $ do
--     height <-
--       into @BlkHeight <$> withBtcT Btc.getBlockCount id
--     hash <-
--       from <$> withBtcT Btc.getBlockHash ($ from height)
--     prev <-
--       from <$> withBtcT Btc.getBlockHash ($ from height - 1)
--     mBlock <-
--       lift Block.getLatest
--     case mBlock of
--       Nothing ->
--         scanBlockT height hash prev
--       Just blockEnt ->
--         when (blockHash (entityVal blockEnt) /= hash) $
--           scanUntilT blockEnt height hash prev
--   whenLeft res $
--     $(logTM) ErrorS . logStr . inspect
--   sleep $ MicroSecondsDelay 1000000
--   apply

apply :: (Env m, Storage (ExceptT Failure m), From (Maybe Btc.BlockHash) BlkPrevHash) => m ()
apply = do
  _r <- runExceptT scan
  sleep $ MicroSecondsDelay 1000000
  apply


getBlockAddresses :: Btc.BlockVerbose -> Set Btc.Address
getBlockAddresses blk =
    S.unions $ V.map extractAddr $
      V.map Btc.scriptPubKey $ V.foldMap Btc.decVout $ Btc.vSubTransactions blk
  where
    extractAddr :: Btc.ScriptPubKey -> Set Btc.Address
    extractAddr (Btc.StandardScriptPubKey _ _ _ _ addrs) = V.foldr S.insert S.empty addrs
    extractAddr _ = S.empty

heighToInt :: BlkHeight -> Integer
heighToInt (BlkHeight c) = c

scan :: (Env m, Storage (ExceptT Failure m), From (Maybe Btc.BlockHash) BlkPrevHash)
     => ExceptT Failure m (Set Btc.Address)
scan = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  case mBlk of
    Nothing -> scanOneBlock cHeight
    Just lBlk -> do
      let s = heighToInt $ blockHeight $ entityVal lBlk
      step S.empty s (heighToInt cHeight)
    where
      step acc cur end = do
        addrs <- scanOneBlock $ BlkHeight cur
        if cur == end
           then pure (acc <> addrs)
           else do
             r <- step acc (cur + 1) end
             pure (acc <> r)


scanOneBlock :: (Env m, From (Maybe Btc.BlockHash) BlkPrevHash, Storage (ExceptT Failure m)) =>
  BlkHeight -> ExceptT Failure m (Set Btc.Address)
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  void $ Block.createUpdate height (from hash) (from $ Btc.vPrevBlock blk)
  pure $ getBlockAddresses blk

-- scanBlockT ::
--   ( Env m
--   ) =>
--   BlkHeight ->
--   BlkHash ->
--   BlkPrevHash ->
--   ExceptT Failure m ()
-- scanBlockT height hash prev = do
--   blk <- withBtcT Btc.getBlock ($ from hash)
--   --
--   -- TODO : !!!
--   --
--   lift $
--     $(logTM) ErrorS . logStr $ inspect blk
--   lift . void $
--     Block.createUpdate height hash prev
--
-- scanUntilT ::
--   ( Env m
--   ) =>
--   Entity Block ->
--   BlkHeight ->
--   BlkHash ->
--   BlkPrevHash ->
--   ExceptT Failure m ()
-- scanUntilT _ _ _ _ =
--   $(logTM) ErrorS "TODO!!!"
