module BtcLsp.Grpc.Method.SwapIntoLn
  ( apply,
  )
where

import BtcLsp.Import
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn

apply ::
  ( Monad m
  ) =>
  Entity User ->
  SwapIntoLn.Request ->
  m SwapIntoLn.Response
apply _ _ =
  pure defMessage
