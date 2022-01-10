module BtcLsp.Thread.Server
  ( apply,
  )
where

import BtcLsp.Import hiding (Sig (..))
import BtcLsp.ProtoLensGrpc.Data
--import Data.Signable (Signable)
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Network.GRPC.Server
import qualified Network.Wai.Internal as Wai
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Custody.OpenChanLn as CustodyOpenChanLn
import qualified Proto.BtcLsp.Custody.OpenChanOnChain as CustodyOpenChanOnChain
import qualified Proto.BtcLsp.General.GetCfg as GeneralGetCfg

apply :: (Env m) => m ()
apply = do
  env <- getGsEnv
  withUnliftIO $ \run ->
    runServer env $ handlers run

handlers ::
  ( Monad m
  ) =>
  UnliftIO m ->
  GSEnv ->
  MVar (Sig 'Server) ->
  [ServiceHandler]
handlers run _ _ =
  [ unary (RPC :: RPC Service "generalGetCfg") . sig $
      generalGetCfg run,
    unary (RPC :: RPC Service "custodyOpenChanLn") . sig $
      custodyOpenChanLn run,
    unary (RPC :: RPC Service "custodyOpenChanOnChain") . sig $
      custodyOpenChanOnChain run
  ]
  where
    --
    -- TODO : enable back signature verification
    -- when client side will be ready.
    --
    -- sig =
    --   withSig env sigVar
    sig ::
      -- ( Signable a,
      --   Signable b
      -- ) =>
      (a -> IO b) ->
      Wai.Request ->
      a ->
      IO b
    sig f =
      const f

generalGetCfg ::
  ( Monad m
  ) =>
  UnliftIO m ->
  GeneralGetCfg.Request ->
  IO GeneralGetCfg.Response
generalGetCfg (UnliftIO run) _ =
  run $ pure defMessage

custodyOpenChanLn ::
  ( Monad m
  ) =>
  UnliftIO m ->
  CustodyOpenChanLn.Request ->
  IO CustodyOpenChanLn.Response
custodyOpenChanLn (UnliftIO run) _ =
  run $ pure defMessage

custodyOpenChanOnChain ::
  ( Monad m
  ) =>
  UnliftIO m ->
  CustodyOpenChanOnChain.Request ->
  IO CustodyOpenChanOnChain.Response
custodyOpenChanOnChain (UnliftIO run) _ =
  run $ pure defMessage
