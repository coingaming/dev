{-# LANGUAGE TypeApplications #-}

module BtcLsp.Time
  ( getCurrentTime,
    getFutureTime,
    getPastTime,
  )
where

import BtcLsp.Data.Orphan ()
import BtcLsp.Import.External
import qualified Data.Time.Clock as Time
import qualified LndClient as Lnd

getCurrentTime :: (MonadIO m) => m UTCTime
getCurrentTime =
  liftIO Time.getCurrentTime

getFutureTime :: (MonadIO m) => Lnd.Seconds -> m UTCTime
getFutureTime ss =
  addSeconds ss <$> liftIO getCurrentTime

getPastTime :: (MonadIO m) => Lnd.Seconds -> m UTCTime
getPastTime ss =
  subSeconds ss <$> liftIO getCurrentTime

addSeconds :: Lnd.Seconds -> UTCTime -> UTCTime
addSeconds =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    . via @Word64

subSeconds :: Lnd.Seconds -> UTCTime -> UTCTime
subSeconds =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    . (* (-1))
    . via @Word64
