{-# LANGUAGE TypeApplications #-}

module BtcLsp.Class.Env
  ( Env (..),
  )
where

import BtcLsp.Class.Storage
import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Grpc.Combinator
import BtcLsp.Grpc.Orphan ()
import BtcLsp.Grpc.Server.LowLevel
import BtcLsp.Import.External
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
  getSwapIntoLnMinAmt :: m (Money 'Usr 'OnChain 'Fund)
  getMsatPerByte :: m (Maybe MSat)
  getLspPubKeyVar :: m (MVar Lnd.NodePubKey)
  getLndP2PSocketAddress :: m SocketAddress
  getLndNodeUri :: m NodeUri
  getLspPubKey :: m Lnd.NodePubKey
  getLspLndEnv :: m Lnd.LndEnv
  getYesodLog :: m YesodLog
  getLndNodeUri =
    NodeUri <$> getLspPubKey <*> getLndP2PSocketAddress
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
            -- NOTE : there is fatal failure here,
            -- because lnd-lsp is meaningless without
            -- operational lnd.
            --
            error $
              "Fatal Lnd failure, can not get NodePubKey: "
                <> inspectPlain e
          Right res -> do
            let pubKey = Lnd.identityPubkey res
            void $ tryPutMVar var pubKey
            pure pubKey
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
  withLndServerT ::
    ( GrpcRes res failure specific
    ) =>
    (Lnd.LndEnv -> a) ->
    (a -> m (Either Lnd.LndError b)) ->
    ExceptT res m b
  withLndServerT method =
    withExceptT newInternalFailure . withLndT method
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
