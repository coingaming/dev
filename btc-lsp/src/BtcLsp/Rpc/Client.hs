{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Client
  ( RpcError (..),
    send,
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.Env
import Data.Text
import Network.Socket
import Network.Socket.ByteString (recv, sendAll)
import qualified UnliftIO.Exception as E

data RpcError
  = RpcNoAddress
  | RpcJsonDecodeError
  | OtherError Text
  deriving (Eq, Generic, Show)

instance Out RpcError

send :: Env m => ByteString -> m (Either RpcError ByteString)
send req = do
  env <- getRpcEnv
  liftIO $
    runTCPClient (unpack $ rpcEnvHost env) (unpack $ rpcEnvPort env) $ \s -> do
      sendAll s $ req <> "\n"
      Right <$> recv s 1024

runTCPClient :: (MonadUnliftIO m) => HostName -> ServiceName -> (Socket -> m (Either RpcError ByteString)) -> m (Either RpcError ByteString)
runTCPClient host port client = withRunInIO $ \x -> do
  addr <- resolve
  case addr of
    Left err -> pure $ Left err
    Right addr0 -> do
      withSocketsDo $ do
        x $
          E.bracket
            (open addr0)
            (liftIO . close)
            client
  where
    resolve :: (MonadUnliftIO m) => m (Either RpcError AddrInfo)
    resolve = do
      liftIO $ maybeToRight RpcNoAddress . safeHead <$> getAddrInfo Nothing (Just host) (Just port)
    open :: (MonadUnliftIO m) => AddrInfo -> m Socket
    open addr = E.bracketOnError ((liftIO . openSocket) addr) (liftIO . close) $ \sock -> do
      _ <- liftIO $ connect sock $ addrAddress addr
      return sock
