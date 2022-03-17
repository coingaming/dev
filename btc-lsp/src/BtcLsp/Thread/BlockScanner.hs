{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scan,
    Utxo (..),
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified Data.Vector as V
import qualified Network.Bitcoin as Btc
import qualified Universum

apply :: (Env m) => m ()
apply = do
  res <- runExceptT scan
  whenLeft res $ $(logTM) ErrorS . logStr . inspect
  whenRight res markFunded
  sleep $ MicroSecondsDelay 1000000
  apply

markFunded :: (Env m) => [Utxo] -> m ()
markFunded utxos =
  mapM_ maybeFundSwap swapIds
  where
    swapIds =
      nubOrd $
        utxoSwapId <$> utxos
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
  foldrM foldTrx [] $
    Btc.vSubTransactions blk
  where
    foldTrx trx acc = do
      utxos <-
        mapM (mapVout $ Btc.decTxId trx)
          . V.toList
          $ Btc.decVout trx
      pure $
        catMaybes utxos <> acc
    mapVout ::
      ( Env m
      ) =>
      Btc.TransactionID ->
      Btc.TxOut ->
      m (Maybe Utxo)
    mapVout txid txout@(Btc.TxOut val num (Btc.StandardScriptPubKey _ _ _ _ addrsV)) =
      case V.toList addrsV of
        [addr] -> do
          mswp <- maybeSwap addr
          case mswp of
            Just swp ->
              newUtxo (tryFrom val) (tryFrom num) txid swp
            Nothing -> do
              $(logTM) DebugS . logStr $
                "Unknown swap in txid: "
                  <> inspect txid
                  <> " and txout: "
                  <> Universum.show txout
              pure Nothing
        _ -> do
          $(logTM) ErrorS . logStr $
            "Unsupported address vector in txid: "
              <> inspect txid
              <> " and txout: "
              <> Universum.show txout
          pure Nothing
    mapVout txid txout = do
      $(logTM) DebugS . logStr $
        "Unsupported txid: "
          <> inspect txid
          <> " and txout: "
          <> Universum.show txout
      pure Nothing
    newUtxo (Right val) (Right n) txid swp =
      pure . Just $
        Utxo val n txid (entityKey swp)
    newUtxo val num txid swp = do
      $(logTM) ErrorS . logStr $
        "TryFrom overflow error val: "
          <> Universum.show val
          <> " num: "
          <> Universum.show num
          <> " txid: "
          <> inspect txid
          <> " and swap: "
          <> inspect swp
      pure Nothing

persistBlockT ::
  ( Storage m
  ) =>
  Btc.BlockVerbose ->
  [Utxo] ->
  ExceptT Failure m ()
persistBlockT blk utxos = do
  height <-
    tryFromT $
      Btc.vBlkHeight blk
  lift . runSql $ do
    b <-
      Block.createUpdateSql
        height
        (from $ Btc.vBlockHash blk)
        (from <$> Btc.vPrevBlock blk)
    ct <-
      getCurrentTime
    SwapUtxo.createManySql $
      toSwapUtxo ct b <$> utxos
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
  cHeight <- tryFromT =<< withBtcT Btc.getBlockCount id
  case mBlk of
    Nothing -> do
      $(logTM) DebugS . logStr $
        "Found no blocks, scanning height: "
          <> inspect cHeight
      scanOneBlock cHeight
    Just lBlk -> do
      $(logTM) DebugS . logStr $
        "Found latest known block: "
          <> inspect lBlk
          <> " scanning to height: "
          <> inspect cHeight
      --
      -- TODO : verify block hash
      --
      let s = from . blockHeight $ entityVal lBlk
      let e = from cHeight
      step [] (1 + s) e
  where
    step acc cur end = do
      $(logTM) DebugS . logStr $
        "Scanner step cur:"
          <> inspect cur
          <> " end: "
          <> inspect end
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
  persistBlockT blk utxos
  pure utxos

maybeSwap ::
  ( Env m
  ) =>
  Btc.Address ->
  m (Maybe (Entity SwapIntoLn))
maybeSwap addr =
  SwapIntoLn.getByFundAddress $ from addr
