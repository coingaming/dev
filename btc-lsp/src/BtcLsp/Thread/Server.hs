{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.Server
  ( apply,
  )
where

import BtcLsp.Grpc.Data
import qualified BtcLsp.Grpc.Method.SwapIntoLn as SwapIntoLn
import BtcLsp.Import hiding (Sig (..))
import qualified BtcLsp.Storage.Model.User as User
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import Lens.Micro
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Network.GRPC.Server
import qualified Network.Wai.Internal as Wai
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Method.GetCfg as GetCfg
import qualified Proto.BtcLsp.Method.SwapFromLn as SwapFromLn

apply :: (Env m) => m ()
apply = do
  env <- getGsEnv
  withUnliftIO $ \run ->
    runServer env $ handlers run

handlers ::
  ( Env m
  ) =>
  UnliftIO m ->
  GSEnv ->
  MVar (Sig 'Server) ->
  [ServiceHandler]
handlers run _ _ =
  [ unary (RPC :: RPC Service "getCfg") $
      withMiddleware run getCfg,
    unary (RPC :: RPC Service "swapIntoLn") $
      withMiddleware run SwapIntoLn.apply,
    unary (RPC :: RPC Service "swapFromLn") $
      withMiddleware run swapFromLn
  ]

withMiddleware ::
  ( HasField req "maybe'ctx" (Maybe Proto.Ctx),
    HasField res "failure" failure,
    HasField failure "input" [Proto.InputFailure],
    HasField failure "internal" [internal],
    Message res,
    Message failure,
    Message internal,
    Env m
  ) =>
  UnliftIO m ->
  (Entity User -> req -> m res) ->
  Wai.Request ->
  req ->
  IO res
withMiddleware (UnliftIO run) handler _ req =
  run $ do
    res <- runExceptT $ do
      nonce <-
        fromReqT $
          req
            ^? field @"maybe'ctx"
              . _Just
              . Proto.maybe'nonce
              . _Just
      pub <-
        fromReqT $
          req
            ^? field @"maybe'ctx"
              . _Just
              . Proto.maybe'lnPubKey
              . _Just
      ExceptT $
        User.createVerify pub nonce
    case res of
      Left e -> pure $ failResE e
      Right user -> handler user req

getCfg ::
  ( Monad m
  ) =>
  Entity User ->
  GetCfg.Request ->
  m GetCfg.Response
getCfg _ _ =
  pure defMessage

swapFromLn ::
  ( Monad m
  ) =>
  Entity User ->
  SwapFromLn.Request ->
  m SwapFromLn.Response
swapFromLn _ _ =
  pure defMessage
