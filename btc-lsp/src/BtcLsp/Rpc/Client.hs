{-# LANGUAGE OverloadedStrings #-}

module BtcLsp.Rpc.Client
  ( send,
  )
where

import BtcLsp.Import
import BtcLsp.Rpc.Env
import Network.Socket
import Network.Socket.ByteString (recv, sendAll)
import qualified UnliftIO.Exception as E

send :: Env m => ByteString -> ElectrsEnv -> m (Either RpcError ByteString)
send req env = do
  liftIO $
    runTCPClient (unpack $ electrsEnvHost env) (unpack $ electrsEnvPort env) $ \s -> do
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
