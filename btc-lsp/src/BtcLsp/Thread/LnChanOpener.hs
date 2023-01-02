{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.LnChanOpener
  ( apply,
    cleanupInPsbtThreadChannels,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Import.Psql as Psql
import qualified BtcLsp.Psbt.PsbtOpener as PO
import BtcLsp.Psbt.Utils (swapUtxoToPsbtUtxo)
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import Control.Concurrent.Extra
import qualified Control.Retry as Retry
import qualified Data.Set as Set
import qualified LndClient as Lnd
import qualified LndClient.Data.ChannelPoint as ChannelPoint
import qualified LndClient.Data.Peer as Peer
import qualified LndClient.RPC.Silent as LndSilent

apply :: (Env m, GenericPrettyEnv m) => m ()
apply = do
  Inspect inspect <- getInspect
  lock <- liftIO newLock
  forever $ do
    ePeerList <-
      withLnd LndSilent.listPeers id
    whenLeft ePeerList $
      $logTM ErrorS
        . logStr
        . ("ListPeers procedure failed: " <>)
        . inspect @Text
    let peerSet =
          Set.fromList $
            Peer.pubKey <$> fromRight [] ePeerList
    swaps <-
      runSql $
        filter
          ( \x ->
              Set.member
                (userNodePubKey . entityVal $ snd x)
                peerSet
          )
          <$> SwapIntoLn.getSwapsWaitingPeerSql
    mapM_
      ( \(swp, usr) -> do
          pcid <- Lnd.newPendingChanId
          void $ runSql $ SwapIntoLn.updateInPsbtThreadSql (entityKey swp) pcid
          spawnLink $
            Retry.retrying
              (Retry.capDelay (3600 * 1000000) $ Retry.fullJitterBackoff 1000)
              ( \rs res -> do
                  $(logTM) DebugS . logStr $
                    ( "Retrying openchan attemp number:"
                        <> inspect @Text (Retry.rsIterNumber rs)
                        <> " prev delay microseconds:"
                        <> inspect @Text (Retry.rsPreviousDelay rs)
                        <> " swap:"
                        <> inspect @Text swp
                    )
                  pure $ isRight res
              )
              $ \_ -> do
                runSql $ do
                  r <- openChanSql pcid lock swp usr
                  whenLeft r $ pure $ SwapIntoLn.updateRevertInPsbtThreadSql $ entityKey swp
                  pure r
      )
      swaps
    sleep300ms

cleanupInPsbtThreadChannels :: Env m => m ()
cleanupInPsbtThreadChannels = runSql $ do
  swaps <- SwapIntoLn.getSwapsInPsbtThreadSql
  mapM_ abortChan swaps
  SwapIntoLn.updateRevertAllInPsbtThreadSql
  where
    abortChan (Entity _ swp) = do
      case swapIntoLnPsbtPendingChanId swp of
        Just pcid -> lift $ PO.abortChannelPsbt pcid
        Nothing -> pure ()

--
-- TODO : Do not open channel in case where
-- there not is enough liquidity to perform swap.
-- Maybe also put some limits into amount of
-- opening chans per user.
--
openChanSql ::
  ( Env m,
    GenericPrettyEnv m
  ) =>
  Lnd.PendingChannelId ->
  Lock ->
  Entity SwapIntoLn ->
  Entity User ->
  ReaderT Psql.SqlBackend m (Either (Entity SwapIntoLn) ())
openChanSql pcid lock (Entity swapKey _) userEnt = do
  Inspect inspect <- lift getInspect
  res <-
    SwapIntoLn.withLockedRowSql swapKey (== SwapInPsbtThread) $
      \swapVal -> do
        utxos <- SwapUtxo.getSpendableUtxosBySwapIdSql swapKey
        cpEither <- lift . runExceptT $ do
          r <-
            PO.openChannelPsbt
              pcid
              lock
              (swapUtxoToPsbtUtxo . entityVal <$> utxos)
              (userNodePubKey $ entityVal userEnt)
              (swapIntoLnLspFeeAndChangeAddress swapVal)
              (swapIntoLnFeeLsp swapVal)
              (swapIntoLnPrivacy swapVal)
          liftIO (wait $ PO.fundAsync r) >>= except
        either
          ( $logTM ErrorS . logStr
              . ("OpenChan procedure failed: " <>)
              . inspect @Text
          )
          ( \cp ->
              LnChan.createUpdateSql
                swapKey
                (ChannelPoint.fundingTxId cp)
                (ChannelPoint.outputIndex cp)
                >> SwapIntoLn.updateWaitingChanSql swapKey
                >> SwapUtxo.updateSpentChanSwappedSql swapKey
          )
          cpEither
  whenLeft res $
    $logTM ErrorS
      . logStr
      . ("Channel opening failed due to wrong status " <>)
      . inspect @Text
  pure res
