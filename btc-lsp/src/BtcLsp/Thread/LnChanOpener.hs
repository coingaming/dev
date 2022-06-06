{-# LANGUAGE TemplateHaskell #-}

module BtcLsp.Thread.LnChanOpener
  ( apply,
  )
where

import BtcLsp.Import
import qualified BtcLsp.Storage.Model.LnChan as LnChan
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import qualified BtcLsp.Storage.Model.SwapUtxo as SwapUtxo
import qualified Data.Set as Set
import qualified LndClient.Data.ChannelPoint as ChannelPoint
import qualified LndClient.Data.OpenChannel as Chan
import qualified LndClient.Data.Peer as Peer
import qualified LndClient.RPC.Katip as LndKatip
import qualified LndClient.RPC.Silent as LndSilent

apply :: (Env m) => m ()
apply =
  forever $ do
    ePeerList <-
      withLnd LndSilent.listPeers id
    whenLeft ePeerList $
      $(logTM) ErrorS
        . logStr
        . ("ListPeers procedure failed: " <>)
        . inspect
    let peerSet =
          Set.fromList $
            Peer.pubKey <$> fromRight [] ePeerList
    swaps <-
      runSql SwapIntoLn.getSwapsWaitingPeerSql
    tasks <-
      mapM
        ( spawnLink
            . uncurry openChan
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

--
-- TODO : Do not open channel in case where
-- there not is enough liquidity to perform swap.
-- Maybe also put some limits into amount of
-- opening chans per user.
--
openChan ::
  ( Env m
  ) =>
  Entity SwapIntoLn ->
  Entity User ->
  m ()
openChan (Entity swapKey _) userEnt = do
  rate <- getMsatPerByte
  res <- runSql
    . SwapIntoLn.withLockedRowSql swapKey (== SwapWaitingPeer)
    $ \swapVal ->
      eitherM
        ( $(logTM) ErrorS . logStr
            . ("OpenChan procedure failed: " <>)
            . inspect
        )
        ( \cp ->
            LnChan.createUpdateSql
              swapKey
              (ChannelPoint.fundingTxId cp)
              (ChannelPoint.outputIndex cp)
              >> SwapIntoLn.updateWaitingChanSql swapKey
              >> SwapUtxo.updateSpentChanSql swapKey
        )
        . lift
        $ withLnd
          LndKatip.openChannelSync
          ( $
              Chan.OpenChannelRequest
                { Chan.nodePubkey =
                    userNodePubKey $
                      entityVal userEnt,
                  Chan.localFundingAmount =
                    from (swapIntoLnChanCapLsp swapVal)
                      + from (swapIntoLnChanCapUser swapVal),
                  Chan.pushMSat = Nothing,
                  Chan.targetConf = Nothing,
                  Chan.mSatPerByte = rate,
                  Chan.private = Just $ swapIntoLnPrivacy swapVal == Private,
                  Chan.minHtlcMsat = Nothing,
                  Chan.remoteCsvDelay = Nothing,
                  Chan.minConfs = Nothing,
                  Chan.spendUnconfirmed = Nothing,
                  Chan.closeAddress = Nothing
                }
          )
  whenLeft res $
    $(logTM) ErrorS
      . logStr
      . ("Channel opening failed due to wrong status " <>)
      . inspect
