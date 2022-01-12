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
import qualified Proto.BtcLsp.Method.GetCfg as GetCfg
import qualified Proto.BtcLsp.Method.SwapFromLn as SwapFromLn
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn

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
  [ unary (RPC :: RPC Service "getCfg") . sig $
      getCfg run,
    unary (RPC :: RPC Service "swapIntoLn") . sig $
      swapIntoLn run,
    unary (RPC :: RPC Service "swapFromLn") . sig $
      swapFromLn run
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

getCfg ::
  ( Monad m
  ) =>
  UnliftIO m ->
  GetCfg.Request ->
  IO GetCfg.Response
getCfg (UnliftIO run) _ =
  run $ pure defMessage

swapIntoLn ::
  ( Monad m
  ) =>
  UnliftIO m ->
  SwapIntoLn.Request ->
  IO SwapIntoLn.Response
swapIntoLn (UnliftIO run) _ =
  run $ pure defMessage

swapFromLn ::
  ( Monad m
  ) =>
  UnliftIO m ->
  SwapFromLn.Request ->
  IO SwapFromLn.Response
swapFromLn (UnliftIO run) _ =
  run $ pure defMessage
