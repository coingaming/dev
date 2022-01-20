{-# LANGUAGE TypeApplications #-}

module BtcLsp.Util
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
addSeconds s =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    --
    -- TODO : replace *integral utils with witch!!!
    --
    . fromIntegral
    $ from @Lnd.Seconds @Word64 s

subSeconds :: Lnd.Seconds -> UTCTime -> UTCTime
subSeconds s =
  addUTCTime
    . fromRational
    . toRational
    . secondsToDiffTime
    . (* (-1))
    . fromIntegral
    $ from @Lnd.Seconds @Word64 s
