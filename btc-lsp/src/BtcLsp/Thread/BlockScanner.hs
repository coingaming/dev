{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module BtcLsp.Thread.BlockScanner
  ( apply,
    scan,
    Utxo (..),
    trySat2MSat,
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
import LndClient (txIdParser)
import qualified Network.Bitcoin.Types as Btc

apply :: (Env m) => [m ()] -> m ()
apply afterScan =
  forever $ do
    eitherM
      ( $(logTM) ErrorS
          . logStr
          . inspect
      )
      (\u -> unless (null u) (markFunded u >> sequence_ afterScan))
      $ runExceptT scan
    sleep $ MicroSecondsDelay 1000000

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
      mCap <- newSwapCapM amt
      debugMsg mCap swapId amt
      whenJust mCap $ \swapCap -> runSql $ do
        SwapUtxo.markAsUsedForChanFundingSql $ entityKey <$> us
        SwapIntoLn.updateFundedSql swapId swapCap

data Utxo = Utxo
  { utxoValue :: MSat,
    utxoN :: Vout 'Funding,
    utxoId :: TxId 'Funding,
    utxoSwapId :: SwapIntoLnId
  }
  deriving (Show)

--
-- TODO: presist log of unsupported transactions

mapVout ::
  ( Env m
  ) =>
  Btc.TransactionID ->
  Btc.TxOut ->
  m (Maybe Utxo)
mapVout txid (Btc.TxOut val num (Btc.StandardScriptPubKeyV22 _ _ _ addr)) =
  handleAddr addr val num txid
mapVout txid txout@(Btc.TxOut val num (Btc.StandardScriptPubKey _ _ _ _ addrsV)) =
  case V.toList addrsV of
    [addr] -> handleAddr addr val num txid
    _ -> do
      $(logTM) ErrorS . logStr $
        "Unsupported address vector in txid: "
          <> inspect txid
          <> " and txout: "
          <> Universum.show txout
      pure Nothing
mapVout _ _ =
  pure Nothing

handleAddr :: Env m => Btc.Address -> Btc.BTC -> Integer -> Btc.TransactionID -> m (Maybe Utxo)
handleAddr addr val num txid = do
  mswp <- maybeSwap addr
  case mswp of
    Just swp -> newUtxo (trySat2MSat val) (tryFrom num) (txIdParser $ Btc.unTransactionID txid) swp
    Nothing -> pure Nothing

newUtxo ::
  (Env m) =>
  Either (TryFromException Btc.BTC MSat) MSat ->
  Either (TryFromException Integer (Vout 'Funding)) (Vout 'Funding) ->
  Either LndError ByteString ->
  Entity SwapIntoLn ->
  m (Maybe Utxo)
newUtxo (Right val) (Right n) (Right txid) swp =
  pure . Just $
    Utxo val n (from txid) (entityKey swp)
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

trySat2MSat ::
  Btc.BTC ->
  Either (TryFromException Btc.BTC MSat) MSat
trySat2MSat =
  from @Word64
    `composeTryRhs` tryFrom @Integer
      `composeTryLhs` fmap (* 1000) from

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
    toSwapUtxo now blkId (Utxo value' n' txid' swpId') = do
      SwapUtxo
        { swapUtxoSwapIntoLnId = swpId',
          swapUtxoBlockId = entityKey blkId,
          swapUtxoTxid = txid',
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
      --
      -- TODO : verify block hash
      --
      let known = from . blockHeight $ entityVal lBlk
      step [] (1 + known) $ from cHeight
  where
    step acc cur end =
      if cur > end
        then pure acc
        else do
          $(logTM) DebugS . logStr $
            "Scanner step cur:"
              <> inspect cur
              <> " end: "
              <> inspect end
              <> " got utxos: "
              <> inspect (length acc)
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
  $(logTM) DebugS . logStr $ "Got new block " <> inspect hash
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
