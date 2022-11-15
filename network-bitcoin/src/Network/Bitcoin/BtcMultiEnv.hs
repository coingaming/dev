{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# OPTIONS_GHC -Wall #-}

module Network.Bitcoin.BtcMultiEnv
  ( BtcMultiEnv (..),
  )
where

import Control.Monad.IO.Class
import Control.Monad.Trans.Except
import Data.Bifunctor (first)
import Network.Bitcoin.BtcEnv (BtcCfg (..), BtcFailure (..), tryBtcMethod)
import Network.Bitcoin.Internal

class (MonadIO m) => BtcMultiEnv m e owner | m -> e owner where
  getBtcCfg :: owner -> m BtcCfg
  getBtcClient :: owner -> m Client
  getBtcFailureMaker :: owner -> m (BtcFailure -> e)
  withBtc :: owner -> (Client -> a) -> (a -> IO b) -> m (Either e b)
  withBtc owner method args = do
    cfg <- getBtcCfg owner
    client <- getBtcClient owner
    failureMaker <- getBtcFailureMaker owner
    first failureMaker <$> tryBtcMethod cfg client method args
  withBtcT :: owner -> (Client -> a) -> (a -> IO b) -> ExceptT e m b
  withBtcT owner method =
    ExceptT . withBtc owner method
