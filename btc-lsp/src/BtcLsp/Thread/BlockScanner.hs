{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

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
import qualified Data.Set as S
import qualified Network.Bitcoin as Btc
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Storage.Model.SwapUtxo as SU


apply :: (Env m) => m ()
apply = do
  res <- runExceptT scan
  whenLeft res $ $(logTM) ErrorS . logStr . inspect
  whenRight res markFunded
  sleep $ MicroSecondsDelay 1000000
  apply


markFunded :: (Env m) => [UtxoVout] -> m ()
markFunded utxos = do
  let swapIds = S.toList $ S.fromList $ utxoSwapId <$> utxos
  sequence_ $ maybeFundSwap <$> swapIds
    where
      lspCap amt = newChanCapLsp $ from amt
      lspFee amt = newSwapIntoLnFee $ from amt
      debugMsg isFunded sid amt = $(logTM) DebugS . logStr $
        if isFunded then "Marking funded "
          <> inspect sid
          <> " with amt: "
          <> inspect amt
          else "Not enought funds for "
          <> inspect sid
          <> " with amt: "
          <> inspect amt
      maybeFundSwap swapId = do
        us <- runSql $ SU.getFundsBySwapIdSql swapId
        let amt = sum $ swapUtxoAmount . entityVal <$> us
        let isEnought = amt >= from swapLnMinAmt
        debugMsg isEnought swapId amt
        when isEnought $ runSql $ do
          void $ SU.markAsUsedForChanFundingSql (entityKey <$> us)
          void $ SwapIntoLn.updateFundedSql
            swapId (from amt) (lspCap amt) (lspFee amt)


data UtxoVout = UtxoVout {
  utxoValue :: Btc.BTC,
  utxoN :: Integer,
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
              Just swp -> pure $ Right $ UtxoVout val num txid (entityKey swp)
              Nothing -> pure $ Left "Unknown address"
    mapVout _ _ = pure $ Left "TODO: unsupported vout"


persistBlock :: (Storage m) => Btc.BlockVerbose -> [UtxoVout] -> m [SwapUtxoId]
persistBlock blk utxos = runSql $ do
  b <- Block.createUpdateSql
    (from $ Btc.vBlkHeight blk)
    (from $ Btc.vBlockHash blk)
    (from <$> Btc.vPrevBlock blk)
  Psql.insertMany $ toSwapUtxo b <$> utxos
  where
    toSwapUtxo blkId (UtxoVout value' n' txid' swpId') =
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
  utxos <- lift $ extractRelatedUtxoFromBlock blk
  void . lift $ persistBlock blk utxos
  pure utxos

maybeSwap :: (Env m) => Btc.Address -> m (Maybe (Entity SwapIntoLn))
maybeSwap addr = SwapIntoLn.getByFundAddress $ from addr
