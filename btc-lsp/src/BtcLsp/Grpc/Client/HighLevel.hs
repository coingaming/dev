module BtcLsp.Grpc.Client.HighLevel
  ( swapIntoLn,
  )
where

import BtcLsp.Import.External
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import Proto.SignableOrphan ()

swapIntoLn ::
  ( MonadIO m
  ) =>
  GCEnv ->
  SwapIntoLn.Request ->
  m (Either Text SwapIntoLn.Response)
swapIntoLn env req =
  liftIO $
    runUnary (RPC :: RPC Service "swapIntoLn") env req
