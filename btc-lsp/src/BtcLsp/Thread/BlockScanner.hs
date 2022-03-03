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

apply :: (Env m) => m ()
apply = do
  res <- runExceptT $ do
    height <-
      into @BlkHeight <$> withBtcT Btc.getBlockCount id
    hash <-
      from <$> withBtcT Btc.getBlockHash ($ from height)
    prev <-
      from <$> withBtcT Btc.getBlockHash ($ from height - 1)
    mBlock <-
      lift Block.getLatest
    case mBlock of
      Nothing ->
        scanBlockT height hash prev
      Just blockEnt ->
        when (blockHash (entityVal blockEnt) /= hash) $
          scanUntilT blockEnt height hash prev
  whenLeft res $
    $(logTM) ErrorS . logStr . inspect
  sleep $ MicroSecondsDelay 1000000
  apply


-- getBlockAddresses :: Btc.BlockVerbose -> ()
-- getBlockAddresses blk = do


scanBlockT ::
  ( Env m
  ) =>
  BlkHeight ->
  BlkHash ->
  BlkPrevHash ->
  ExceptT Failure m ()
scanBlockT height hash prev = do
  blk <- withBtcT Btc.getBlock ($ from hash)
  --
  -- TODO : !!!
  --
  lift $
    $(logTM) ErrorS . logStr $ inspect blk
  lift . void $
    Block.createUpdate height hash prev

scanUntilT ::
  ( Env m
  ) =>
  Entity Block ->
  BlkHeight ->
  BlkHash ->
  BlkPrevHash ->
  ExceptT Failure m ()
scanUntilT _ _ _ _ =
  $(logTM) ErrorS "TODO!!!"
