{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapUpdates
  ( getSwapUpdatesR,
    getSwapUpdate,
  )
where

import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import BtcLsp.Time
import BtcLsp.Yesod.Import
import qualified Data.ByteString.Base64.URL as B64
import Data.ByteString.Char8 as C8
import qualified Data.ByteString.Lazy as L
import qualified Data.Digest.Pure.SHA as SHA
  ( bytestringDigest,
    sha256,
  )
import qualified Universum as U

getSwapUpdatesR :: Uuid 'SwapIntoLnTable -> SwapHash -> Handler (Maybe SwapHash)
getSwapUpdatesR uuid swapHash = do
  app <- getYesod
  getSwapUpdateRec app uuid swapHash 60

getSwapUpdateRec :: MonadHandler m => App -> Uuid 'SwapIntoLnTable -> SwapHash -> Integer -> m (Maybe SwapHash)
getSwapUpdateRec app uuid swapHash counter = do
  currentSwapUpdate <- getSwapUpdate app uuid
  if Just swapHash == currentSwapUpdate && counter > 0
    then do
      sleep5s
      getSwapUpdateRec app uuid swapHash (counter - 1)
    else return currentSwapUpdate

getSwapUpdate :: MonadHandler m => App -> Uuid 'SwapIntoLnTable -> m (Maybe SwapHash)
getSwapUpdate (App {appMRunner = UnliftIO run}) uuid =
  (SwapHash . hashFunc)
    U.<<$>> (liftIO . run . runSql . SwapIntoLn.getByUuidSql) uuid

hashFunc :: SwapIntoLn.SwapInfo -> Text
hashFunc =
  decodeUtf8
    . B64.encode
    . L.toStrict
    . SHA.bytestringDigest
    . SHA.sha256
    . L.fromStrict
    . C8.pack
    . show
    . (\x -> x {SwapIntoLn.swapInfoChan = []})
