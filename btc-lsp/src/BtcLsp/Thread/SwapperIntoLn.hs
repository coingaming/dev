{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.SwapperIntoLn
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified Data.Set as Set
import qualified LndClient.Data.ChannelPoint as ChannelPoint
import qualified LndClient.Data.OpenChannel as Chan
import qualified LndClient.Data.Peer as Peer
import qualified LndClient.RPC.Katip as Lnd

apply :: (Env m) => m ()
apply = do
  peerList <- fromRight [] <$> withLnd Lnd.listPeers id
  let peerSet = Set.fromList $ Peer.pubKey <$> peerList
  swaps <- SwapIntoLn.getFundedSwaps
  tasks <-
    mapM
      ( spawnLink
          . openChan
      )
      $ filter
        ( \x ->
            Set.member
              (userNodePubKey . entityVal $ snd x)
              peerSet
        )
        swaps
  mapM_ (liftIO . wait) tasks
  sleep $ MicroSecondsDelay 500000
  apply

--
-- TODO : do not open channel in case where
-- there is enough liquidity to perform swap.
--
openChan :: (Env m) => (Entity SwapIntoLn, Entity User) -> m ()
openChan (swapEnt, userEnt) = do
  let swap = entityVal swapEnt
  res <- runExceptT $ do
    cp <-
      withLndT
        Lnd.openChannelSync
        ( $
            Chan.OpenChannelRequest
              { Chan.nodePubkey =
                  userNodePubKey $
                    entityVal userEnt,
                Chan.localFundingAmount =
                  from (swapIntoLnChanCapLsp swap)
                    + from (swapIntoLnChanCapUser swap),
                Chan.pushMSat = Nothing,
                Chan.targetConf = Nothing,
                Chan.mSatPerByte = Nothing,
                Chan.private = Nothing,
                Chan.minHtlcMsat = Nothing,
                Chan.remoteCsvDelay = Nothing,
                Chan.minConfs = Nothing,
                Chan.spendUnconfirmed = Nothing,
                Chan.closeAddress = Nothing
              }
        )
    lift $
      LnChan.createIgnore
        (entityKey swapEnt)
        (ChannelPoint.fundingTxId cp)
        (ChannelPoint.outputIndex cp)
        LnChanStatusPendingOpen
  whenLeft res $
    $(logTM) ErrorS . logStr
      . ("OpenChan procedure failed: " <>)
      . inspect
