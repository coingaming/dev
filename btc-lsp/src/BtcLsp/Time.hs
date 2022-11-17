{-# LANGUAGE TypeApplications #-}

module BtcLsp.Time
  ( getCurrentTime,
    getFutureTime,
    getPastTime,
    addSeconds,
    subSeconds,
    swapExpiryLimit,
    sleep300ms,
    sleep1s,
    sleep5s,
    sleep10s,
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified Data.Time.Clock as Time
import qualified LndClient as Lnd
import qualified LndClient.Util as Util

getCurrentTime :: (MonadIO m) => m UTCTime
getCurrentTime =
  liftIO Time.getCurrentTime

getFutureTime :: (MonadIO m) => Lnd.Seconds -> m UTCTime
getFutureTime ss =
  addSeconds ss <$> liftIO getCurrentTime

getPastTime :: (MonadIO m) => Lnd.Seconds -> m UTCTime
getPastTime ss =
  subSeconds ss
    <$> liftIO getCurrentTime

addSeconds :: Lnd.Seconds -> UTCTime -> UTCTime
addSeconds =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    . via @Natural

subSeconds :: Lnd.Seconds -> UTCTime -> UTCTime
subSeconds =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    . (* (-1))
    . via @Natural

swapExpiryLimit :: Lnd.Seconds
swapExpiryLimit =
  Lnd.Seconds $ 24 * 60 * 60

sleep300ms :: (MonadIO m) => m ()
sleep300ms =
  Util.sleep $ Util.MicroSecondsDelay 300000

sleep1s :: (MonadIO m) => m ()
sleep1s =
  Util.sleep $ Util.MicroSecondsDelay 1000000

sleep5s :: (MonadIO m) => m ()
sleep5s =
  Util.sleep $ Util.MicroSecondsDelay 5000000

sleep10s :: (MonadIO m) => m ()
sleep10s =
  Util.sleep $ Util.MicroSecondsDelay 10000000
