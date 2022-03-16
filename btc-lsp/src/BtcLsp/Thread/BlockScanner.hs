{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scan,
    Utxo (..),
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified Data.Set as S
import qualified Data.Vector as V
import qualified Network.Bitcoin as Btc

apply :: (Env m) => m ()
apply = do
  res <- runExceptT scan
  whenLeft res $ $(logTM) ErrorS . logStr . inspect
  whenRight res markFunded
  sleep $ MicroSecondsDelay 1000000
  apply

markFunded :: (Env m) => [Utxo] -> m ()
markFunded utxos = do
  sequence_ $
    maybeFundSwap <$> swapIds
  where
    swapIds =
      S.toList . S.fromList $ utxoSwapId <$> utxos
    debugMsg mCap sid amt =
      $(logTM) DebugS . logStr $
        maybe
          ( "Not enought funds for "
              <> inspect sid
              <> " with amt: "
              <> inspect amt
          )
          ( \cap ->
              "Marking funded "
                <> inspect sid
                <> " with amt: "
                <> inspect amt
                <> " and cap: "
                <> inspect cap
          )
          mCap
    maybeFundSwap swapId = do
      us <- runSql $ SwapUtxo.getFundsBySwapIdSql swapId
      let amt = sum $ swapUtxoAmount . entityVal <$> us
      let mCap = newSwapCap amt
      debugMsg mCap swapId amt
      whenJust mCap $ \swapCap -> runSql $ do
        SwapUtxo.markAsUsedForChanFundingSql $ entityKey <$> us
        SwapIntoLn.updateFundedSql swapId swapCap

data Utxo = Utxo
  { utxoValue :: MSat,
    utxoN :: Vout 'Funding,
    utxoId :: Btc.TransactionID,
    utxoSwapId :: SwapIntoLnId
  }
  deriving (Show)

--
-- TODO: presist log of unsupported transactions
--
extractRelatedUtxoFromBlock :: (Env m) => Btc.BlockVerbose -> m [Utxo]
extractRelatedUtxoFromBlock blk =
  foldrM foldTrx [] $ Btc.vSubTransactions blk
  where
    foldTrx trx acc = do
      vouts <-
        mapM (mapVout $ Btc.decTxId trx)
          . V.toList
          $ Btc.decVout trx
      let rVouts = rights vouts
      pure $
        if null rVouts
          then acc
          else rVouts <> acc
    mapVout ::
      ( Env m
      ) =>
      Btc.TransactionID ->
      Btc.TxOut ->
      m (Either Text Utxo)
    mapVout txid (Btc.TxOut val num (Btc.StandardScriptPubKey _ _ _ _ addrsV)) = do
      if V.length addrsV /= 1
        then pure $ Left "TODO: unsupported vout"
        else do
          let addr = V.head addrsV
          mswp <- maybeSwap addr
          case mswp of
            Just swp -> pure $ utxo (tryFrom val) (tryFrom num) txid swp
            Nothing -> pure $ Left "Unknown address"
    mapVout _ _ =
      pure $ Left "TODO: unsupported vout"
    utxo (Right val) (Right n) txid swp =
      Right $ Utxo val n txid (entityKey swp)
    utxo _ _ _ _ =
      Left "vout number overflow"

persistBlock :: (Storage m) => Btc.BlockVerbose -> [Utxo] -> m ()
persistBlock blk utxos = runSql $ do
  b <-
    Block.createUpdateSql
      (from $ Btc.vBlkHeight blk)
      (from $ Btc.vBlockHash blk)
      (from <$> Btc.vPrevBlock blk)
  ct <- getCurrentTime
  SwapUtxo.createManySql $ toSwapUtxo ct b <$> utxos
  where
    toSwapUtxo now blkId (Utxo value' n' txid' swpId') =
      SwapUtxo
        { swapUtxoSwapIntoLnId = swpId',
          swapUtxoBlockId = entityKey blkId,
          swapUtxoTxid = from txid',
          swapUtxoVout = n',
          swapUtxoAmount = from value',
          swapUtxoStatus = SwapUtxoFirstSeen,
          swapUtxoInsertedAt = now,
          swapUtxoUpdatedAt = now
        }

scan ::
  ( Env m
  ) =>
  ExceptT Failure m [Utxo]
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
  ExceptT Failure m [Utxo]
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  utxos <- lift $ extractRelatedUtxoFromBlock blk
  lift $ persistBlock blk utxos
  pure utxos

maybeSwap ::
  ( Env m
  ) =>
  Btc.Address ->
  m (Maybe (Entity SwapIntoLn))
maybeSwap addr =
  SwapIntoLn.getByFundAddress $ from addr
