{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scan,
    UtxoVout(..)
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified Data.Vector as V
import qualified Network.Bitcoin as Btc
import qualified BtcLsp.Import.Psql as Psql


apply :: (Env m) => m ()
apply = do
  res <- runExceptT scan
  whenLeft res $ $(logTM) ErrorS . logStr . inspect
  sleep $ MicroSecondsDelay 1000000
  apply

_markInDb :: (Env m) => (Btc.Address, MSat) -> m ()
_markInDb (addr, amt) = do
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


data UtxoVout = UtxoVout {
  utxoValue :: Btc.BTC,
  utxoN :: Integer,
  utxoAddress :: Btc.Address,
  utxoId :: Btc.TransactionID,
  utxoSwapId :: SwapIntoLnId
} deriving Show

-- TODO: presist log of unsupported transactions
extractRelatedUtxoFromBlock :: (Env m) => Btc.BlockVerbose -> m [UtxoVout]
extractRelatedUtxoFromBlock blk = foldrM foldTrx [] $ Btc.vSubTransactions blk
  where
    foldTrx trx acc = do
      vouts <- mapM (mapVout $ Btc.decTxId trx) $ V.toList $ Btc.decVout trx
      let rVouts = rights vouts
      pure $ if null rVouts
         then acc
         else rVouts <> acc
    mapVout :: (Env m) => Btc.TransactionID -> Btc.TxOut -> m (Either Text UtxoVout)
    mapVout txid (Btc.TxOut val num (Btc.StandardScriptPubKey _ _ _ _ addrsV)) = do
      if V.length addrsV /= 1
         then pure $ Left "TODO: unsupported vout"
         else do
           let addr = V.head addrsV
           mswp <- maybeSwap addr
           case mswp of
              Just swp -> pure $ Right $ UtxoVout val num addr txid (entityKey swp)
              Nothing -> pure $ Left "Unknown address"
    mapVout _ _ = pure $ Left "TODO: unsupported vout"


persistBlock :: (Storage m) => Btc.BlockVerbose -> [UtxoVout] -> m ()
persistBlock blk utxos = runSql $ do
  b <- Block.createUpdateSql
    (from $ Btc.vBlkHeight blk)
    (from $ Btc.vBlockHash blk)
    (from <$> Btc.vPrevBlock blk)
  void $ Psql.insertMany $ toSwapUtxo b <$> utxos
  where
    toSwapUtxo blkId (UtxoVout value' n' _ txid' swpId') =
     SwapUtxo {
        swapUtxoSwapIntoLnId = swpId',
        swapUtxoBlockId = entityKey blkId,
        swapUtxoTxid = from txid',
        swapUtxoVout = from n',
        swapUtxoAmount = from value',
        swapUtxoStatus = SwapUtxoFirstSeen
      }

scan ::
  ( Env m
  ) =>
  ExceptT Failure m [UtxoVout]
scan = do
  mBlk <- lift Block.getLatest
  cHeight <- into @BlkHeight <$> withBtcT Btc.getBlockCount id
  case mBlk of
    Nothing ->
      scanOneBlock cHeight
    Just lBlk -> do
      let s = from . blockHeight $ entityVal lBlk
      let e = from cHeight
      step [] (1 + s) e
  where
    step acc cur end = do
      if cur > end
        then pure acc
        else do
          utxos <- scanOneBlock (BlkHeight cur)
          step (acc <> utxos) (cur + 1) end

scanOneBlock ::
  ( Env m
  ) =>
  BlkHeight ->
  ExceptT Failure m [UtxoVout]
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  traceShowM blk
  utxos <- lift $ extractRelatedUtxoFromBlock blk
  traceShowM utxos
  void . lift $ persistBlock blk utxos
  pure utxos

maybeSwap :: (Env m) => Btc.Address -> m (Maybe (Entity SwapIntoLn))
maybeSwap addr = SwapIntoLn.getByFundAddress $ from addr
