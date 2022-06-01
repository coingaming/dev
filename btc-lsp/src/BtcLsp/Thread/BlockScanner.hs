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
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Math.OnChain as Math
import qualified BtcLsp.Storage.Model.Block as Block
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified Data.ByteString.Lazy as L
import qualified Data.Digest.Pure.SHA as SHA
  ( bytestringDigest,
    sha256,
  )
import qualified Data.Vector as V
import LndClient (txIdParser)
import qualified LndClient.Data.LeaseOutput as LO
import qualified LndClient.Data.OutPoint as OP
import LndClient.RPC.Katip
import qualified Network.Bitcoin as Btc
import qualified Network.Bitcoin.BlockChain as Btc
import qualified Network.Bitcoin.Types as Btc
import qualified Universum

apply :: (Env m) => m ()
apply =
  forever $ do
    eitherM
      ( $(logTM) ErrorS
          . logStr
          . inspect
      )
      maybeFunded
      $ runExceptT scan
    sleep $
      MicroSecondsDelay 1000000

maybeFunded :: (Env m) => [Utxo] -> m ()
maybeFunded [] =
  pure ()
maybeFunded utxos =
  mapM_ maybeFundSwap
    . nubOrd
    $ utxoSwapId <$> utxos

maybeFundSwap :: (Env m) => SwapIntoLnId -> m ()
maybeFundSwap swapId = do
  res <- runSql
    . SwapIntoLn.withLockedRowSql
      swapId
      (`elem` swapStatusChain)
    $ \swapVal -> do
      us <- SwapUtxo.getSpendableUtxosBySwapIdSql swapId
      let amt = sum $ swapUtxoAmount . entityVal <$> us
      mCap <- lift $ newSwapCapM amt
      $(logTM) DebugS . logStr $
        maybe
          ( "Not enough funds for "
              <> inspect swapId
              <> " with amt = "
              <> inspect amt
          )
          ( \cap ->
              "Marking funded "
                <> inspect swapId
                <> " with amt = "
                <> inspect amt
                <> " and cap = "
                <> inspect cap
          )
          mCap
      whenJust mCap $ \swapCap -> do
        qty <-
          SwapUtxo.updateUnspentChanReserveSql $
            entityKey <$> us
        if qty /= from (length us)
          then do
            Psql.transactionUndo
            $(logTM) ErrorS . logStr $
              "Funding update "
                <> inspect swapVal
                <> " failed for UTXOs "
                <> inspect us
          else
            SwapIntoLn.updateWaitingPeerSql
              swapId
              swapCap
  whenLeft res $
    $(logTM) WarningS
      . logStr
      . ("Funding failed due to wrong status " <>)
      . inspect

data Utxo = Utxo
  { utxoAmt :: MSat,
    utxoVout :: Vout 'Funding,
    utxoTxId :: TxId 'Funding,
    utxoSwapId :: SwapIntoLnId,
    utxoLockId :: Maybe UtxoLockId
  }
  deriving stock (Show)

--
-- TODO: presist log of unsupported transactions
--
mapVout ::
  ( Env m
  ) =>
  Btc.TransactionID ->
  Btc.TxOut ->
  m (Maybe Utxo)
mapVout txid (Btc.TxOut amt vout (Btc.StandardScriptPubKeyV22 _ _ _ addr)) =
  handleAddr addr amt vout txid
mapVout txid txout@(Btc.TxOut amt vout (Btc.StandardScriptPubKey _ _ _ _ addrsV)) =
  case V.toList addrsV of
    [addr] -> handleAddr addr amt vout txid
    _ -> do
      $(logTM) ErrorS . logStr $
        "Unsupported address vector in txid = "
          <> inspect txid
          <> " and txout = "
          <> Universum.show txout
      pure Nothing
mapVout _ _ =
  pure Nothing

handleAddr ::
  ( Env m
  ) =>
  Btc.Address ->
  Btc.BTC ->
  Integer ->
  Btc.TransactionID ->
  m (Maybe Utxo)
handleAddr addr amt vout txid = do
  mswp <- maybeSwap addr
  case mswp of
    Just swp ->
      newUtxo
        (Math.trySatToMsat amt)
        (tryFrom vout)
        (txIdParser $ Btc.unTransactionID txid)
        swp
    Nothing ->
      pure Nothing

newUtxo ::
  ( Env m
  ) =>
  Either Failure MSat ->
  Either (TryFromException Integer (Vout 'Funding)) (Vout 'Funding) ->
  Either LndError ByteString ->
  Entity SwapIntoLn ->
  m (Maybe Utxo)
newUtxo (Right amt) (Right n) (Right txid) swp =
  pure . Just $
    Utxo amt n (from txid) (entityKey swp) Nothing
newUtxo amt vout txid swp = do
  $(logTM) ErrorS . logStr $
    "TryFrom overflow error amt = "
      <> Universum.show amt
      <> " vout = "
      <> Universum.show vout
      <> " txid = "
      <> inspect txid
      <> " and swap = "
      <> inspect swp
  pure Nothing

extractRelatedUtxoFromBlock ::
  ( Env m
  ) =>
  Btc.BlockVerbose ->
  m [Utxo]
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

persistBlockT ::
  ( Storage m,
    Env m
  ) =>
  Btc.BlockVerbose ->
  [Utxo] ->
  ExceptT Failure m ()
persistBlockT blk utxos = do
  height <-
    tryFromT $
      Btc.vBlkHeight blk
  lift . runSql $ do
    blockId <-
      entityKey
        <$> Block.createUpdateConfirmedSql
          height
          (from $ Btc.vBlockHash blk)
          (from <$> Btc.vPrevBlock blk)
    ct <-
      getCurrentTime
    res <-
      Block.withLockedRowSql blockId (== BlkConfirmed)
        . const
        $ do
          SwapUtxo.createIgnoreManySql $
            newSwapUtxo ct blockId <$> utxos
          --
          -- TODO : Fix this!!! mapM_ is redundant
          -- and utxo list might be wrong!!!
          --
          mapM_
            (SwapUtxo.updateRefundBlockIdSql blockId)
            (utxoTxId <$> utxos)
    whenLeft res $
      $(logTM) ErrorS
        . logStr
        . ("UTXOs are not persisted for the block " <>)
        . inspect

newSwapUtxo :: UTCTime -> BlockId -> Utxo -> SwapUtxo
newSwapUtxo ct blkId utxo = do
  SwapUtxo
    { swapUtxoSwapIntoLnId = utxoSwapId utxo,
      swapUtxoBlockId = blkId,
      swapUtxoTxid = utxoTxId utxo,
      swapUtxoVout = utxoVout utxo,
      swapUtxoAmount = from amt,
      swapUtxoStatus =
        if amt >= Math.trxDustLimit
          then SwapUtxoUnspent
          else SwapUtxoUnspentDust,
      swapUtxoRefundTxId = Nothing,
      swapUtxoRefundBlockId = Nothing,
      swapUtxoLockId = utxoLockId utxo,
      swapUtxoInsertedAt = ct,
      swapUtxoUpdatedAt = ct
    }
  where
    amt = utxoAmt utxo

scan ::
  ( Env m
  ) =>
  ExceptT Failure m [Utxo]
scan = do
  mBlk <- lift $ runSql Block.getLatestSql
  cHeight <- tryFromT =<< withBtcT Btc.getBlockCount id
  case mBlk of
    Nothing -> do
      $(logTM) DebugS . logStr $
        "Found no blocks, scanning height = "
          <> inspect cHeight
      scanOneBlock cHeight
    Just lBlk -> do
      reorgDetected <- detectReorg lBlk
      case reorgDetected of
        Nothing -> do
          let known = from . blockHeight $ entityVal lBlk
          scannerStep [] (1 + known) $ from cHeight
        Just height -> do
          $(logTM) WarningS . logStr $
            "Reorg detected from height = "
              <> inspect height
          bHeight <- tryFromT height
          withExceptT
            ( FailureInternal
                . ("Block scanner failed due to bad status " <>)
                . inspectPlain
            )
            . ExceptT
            . runSql
            . Block.withLockedRowSql
              (entityKey lBlk)
              (== BlkConfirmed)
            . const
            $ do
              blks <- Block.getBlocksHigherSql bHeight
              Block.updateOrphanHigherSql bHeight
              SwapUtxo.revertRefundedSql (entityKey <$> blks)
              SwapUtxo.updateOrphanSql (entityKey <$> blks)
          scannerStep [] (1 + coerce bHeight) $ from cHeight

scannerStep ::
  ( Env m
  ) =>
  [Utxo] ->
  Word64 ->
  Word64 ->
  ExceptT Failure m [Utxo]
scannerStep acc cur end =
  if cur > end
    then pure acc
    else do
      $(logTM) DebugS . logStr $
        "Scanner step cur = "
          <> inspect cur
          <> " end = "
          <> inspect end
          <> " got utxos qty = "
          <> inspect (length acc)
      utxos <- scanOneBlock (BlkHeight cur)
      scannerStep (acc <> utxos) (cur + 1) end

detectReorg ::
  ( Env m
  ) =>
  Entity Block ->
  ExceptT Failure m (Maybe Btc.BlockHeight)
detectReorg blk = do
  cReorgHeight <- checkReorgHeight cHeight
  pure $
    if cReorgHeight == cHeight
      then Nothing
      else Just cReorgHeight
  where
    cHeight =
      from . blockHeight $ entityVal blk

checkReorgHeight ::
  ( Env m
  ) =>
  Btc.BlockHeight ->
  ExceptT Failure m Btc.BlockHeight
checkReorgHeight bHeight = do
  res <- compareHash bHeight
  case res of
    Just True -> pure bHeight
    Just False -> checkReorgHeight (bHeight - 1)
    Nothing -> pure bHeight

compareHash ::
  ( Env m
  ) =>
  Btc.BlockHeight ->
  ExceptT Failure m (Maybe Bool)
compareHash height = do
  cHash <- withBtcT Btc.getBlockHash ($ height)
  lift
    . ( (== cHash)
          . coerce
          . blockHash
          . entityVal
          <<$>>
      )
    . (listToMaybe <$>)
    . runSql
    . Block.getBlockByHeightSql
    . BlkHeight
    $ fromIntegral height

scanOneBlock ::
  ( Env m
  ) =>
  BlkHeight ->
  ExceptT Failure m [Utxo]
scanOneBlock height = do
  hash <- withBtcT Btc.getBlockHash ($ from height)
  blk <- withBtcT Btc.getBlockVerbose ($ hash)
  $(logTM) DebugS . logStr $
    "Got new block with height = "
      <> inspect height
      <> " and hash = "
      <> inspect hash
  utxos <- lift $ extractRelatedUtxoFromBlock blk
  lockedUtxos <- lockUtxos utxos
  persistBlockT blk lockedUtxos
  pure utxos

newLockId :: Utxo -> UtxoLockId
newLockId u =
  UtxoLockId
    . L.toStrict
    . SHA.bytestringDigest
    . SHA.sha256
    $ txid <> ":" <> vout
  where
    txid = L.fromStrict . coerce $ utxoTxId u
    vout = Universum.show $ utxoVout u

--
-- TODO : Verify that it's possible to lock already locked UTXO.
-- It's corner case where UTXO has been locked but storage
-- procedure later failed.
--
lockUtxo :: (Env m) => Utxo -> ExceptT Failure m Utxo
lockUtxo u = do
  void $
    withLndT
      leaseOutput
      ($ LO.LeaseOutputRequest (coerce lockId) (Just outP) expS)
  pure
    u
      { utxoLockId = Just lockId
      }
  where
    expS :: Word64 = 3600 * 24 * 365 * 10
    outP = OP.OutPoint (coerce $ utxoTxId u) (coerce $ utxoVout u)
    lockId = newLockId u

lockUtxos :: (Env m) => [Utxo] -> ExceptT Failure m [Utxo]
lockUtxos =
  mapM lockUtxo

maybeSwap ::
  ( Env m
  ) =>
  Btc.Address ->
  m (Maybe (Entity SwapIntoLn))
maybeSwap =
  runSql
    . SwapIntoLn.getByFundAddressSql
    . from
