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
    mBlock <-
      lift Block.getLatest
    case mBlock of
      Nothing ->
        scanBlockT hash
      Just block ->
        when (blockHash (entityVal block) /= hash) $
          scanBlockT hash
  whenLeft res $
    $(logTM) ErrorS . logStr . inspect
  sleep $ MicroSecondsDelay 1000000
  apply

scanBlockT :: (Env m) => BlkHash -> ExceptT Failure m ()
scanBlockT _ =
  $(logTM) ErrorS "TODO!!!"
