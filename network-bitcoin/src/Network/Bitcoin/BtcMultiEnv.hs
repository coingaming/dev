{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -Wall #-}

module Network.Bitcoin.BtcMultiEnv
  ( BtcMultiEnv (..),
  )
where

import Control.Monad.IO.Class
import Control.Monad.Trans.Except
import Network.Bitcoin.BtcEnv (BtcCfg (..), BtcFailure (..), tryBtcMethod)
import Network.Bitcoin.Internal

class (MonadIO m) => BtcMultiEnv m owner where
  getBtcCfg :: owner -> m BtcCfg
  getBtcClient :: owner -> m Client
  withBtc :: owner -> (Client -> a) -> (a -> IO b) -> m (Either BtcFailure b)
  withBtc owner method args = do
    cfg <- getBtcCfg owner
    client <- getBtcClient owner
    tryBtcMethod cfg client method args
  withBtcT :: owner -> (Client -> a) -> (a -> IO b) -> ExceptT BtcFailure m b
  withBtcT owner method =
    ExceptT . withBtc owner method
