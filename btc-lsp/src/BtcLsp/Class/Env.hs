{-# LANGUAGE TypeApplications #-}

module BtcLsp.Class.Env
  ( Env (..),
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Data.Type
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Grpc.Server.LowLevel
import BtcLsp.Import.External
import BtcLsp.Rpc.Env
import Data.ProtoLens.Field
import qualified LndClient as Lnd
import qualified LndClient.Data.GetInfo as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.Bitcoin as Btc
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto

class
  ( MonadUnliftIO m,
    KatipContext m,
    Storage m
  ) =>
  Env m
  where
  getGsEnv :: m GSEnv
  getBtcEnv :: m BitcoindEnv
  getLspPubKeyVar :: m (MVar Lnd.NodePubKey)
  getLspLndSocketAddress :: m SocketAddress
  getLspPubKey :: m Lnd.NodePubKey
  getLspPubKey = do
    var <- getLspPubKeyVar
    mPubKey <- tryReadMVar var
    case mPubKey of
      Just pubKey ->
        pure pubKey
      Nothing -> do
        eRes <- withLnd Lnd.getInfo id
        case eRes of
          Left e ->
            --
            -- TODO : do we want fatal fail there?
            --
            error $
              "Fatal Lnd failure, can not get NodePubKey: "
                <> inspectPlain e
          Right res -> do
            let pubKey = Lnd.identityPubkey res
            void $ tryPutMVar var pubKey
            pure pubKey
  getLspPubKeyT :: ExceptT Failure m Lnd.NodePubKey
  getLspPubKeyT =
    lift getLspPubKey
  setGrpcCtx ::
    ( HasField msg "ctx" Proto.Ctx
    ) =>
    msg ->
    m msg
  setGrpcCtx message = do
    nonce <- newNonce
    pubKey <- getLspPubKey
    pure $
      message
        & field @"ctx"
          .~ ( defMessage
                 & Proto.nonce
                   .~ from @Nonce @Proto.Nonce nonce
                 & Proto.lnPubKey
                   .~ from @Lnd.NodePubKey @Proto.LnPubKey pubKey
             )
  setGrpcCtxT ::
    ( HasField msg "ctx" Proto.Ctx
    ) =>
    msg ->
    ExceptT Failure m msg
  setGrpcCtxT =
    lift . setGrpcCtx
  withLnd ::
    (Lnd.LndEnv -> a) ->
    (a -> m (Either Lnd.LndError b)) ->
    m (Either Failure b)
  withLndT ::
    (Lnd.LndEnv -> a) ->
    (a -> m (Either Lnd.LndError b)) ->
    ExceptT Failure m b
  withLndT method =
    ExceptT . withLnd method
  withElectrs ::
    (ElectrsEnv -> a) ->
    (a -> m (Either RpcError b)) ->
    m (Either Failure b)
  withElectrsT ::
    (ElectrsEnv -> a) ->
    (a -> m (Either RpcError b)) ->
    ExceptT Failure m b
  withElectrsT method =
    ExceptT . withElectrs method
  withBtc ::
    (Btc.Client -> a) ->
    (a -> IO b) ->
    m (Either Failure b)
  withBtcT ::
    (Btc.Client -> a) ->
    (a -> IO b) ->
    ExceptT Failure m b
  withBtcT method =
    ExceptT . withBtc method
