module Lsp.Thread.Server
  ( apply,
  )
where

import Data.Signable (Signable)
import Lsp.Import hiding (Sig (..))
import Lsp.ProtoLensGrpc.Data
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Network.GRPC.Server
import qualified Network.Wai.Internal as Wai
import Proto.Lsp (Service)
import qualified Proto.Lsp.Custody.DepositLn as CustodyDepositLn
import qualified Proto.Lsp.Custody.DepositOnChain as CustodyDepositOnChain

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
handlers run env sigVar =
  [ unary (RPC :: RPC Service "custodyDepositOnChain") . sig $
      custodyDepositOnChain run,
    unary (RPC :: RPC Service "custodyDepositLn") . sig $
      custodyDepositLn run
  ]
  where
    sig ::
      ( Signable a,
        Signable b
      ) =>
      (a -> IO b) ->
      Wai.Request ->
      a ->
      IO b
    sig =
      withSig env sigVar

custodyDepositOnChain ::
  ( Monad m
  ) =>
  UnliftIO m ->
  CustodyDepositOnChain.Request ->
  IO CustodyDepositOnChain.Response
custodyDepositOnChain (UnliftIO run) _ =
  run $ pure defMessage

custodyDepositLn ::
  ( Monad m
  ) =>
  UnliftIO m ->
  CustodyDepositLn.Request ->
  IO CustodyDepositLn.Response
custodyDepositLn (UnliftIO run) _ =
  run $ pure defMessage
