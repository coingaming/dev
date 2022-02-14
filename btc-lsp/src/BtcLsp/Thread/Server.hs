{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.Server
  ( apply,
  )
where

import qualified BtcLsp.Grpc.Server.HighLevel as Server
import qualified BtcLsp.Grpc.Sig as SU
import BtcLsp.Import
import qualified BtcLsp.Storage.Model.User as User
import qualified Crypto.Secp256k1 as C
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

type HasContext req = (HasField req "maybe'ctx" (Maybe Proto.Ctx))

type ContextMsg req res failure internal =
  ( HasField req "maybe'ctx" (Maybe Proto.Ctx),
    HasField res "ctx" Proto.Ctx,
    HasField res "failure" failure,
    HasField failure "input" [Proto.InputFailure],
    HasField failure "internal" [internal],
    Message res,
    Message failure,
    Message internal
  )

handlers ::
  forall m.
  ( Env m
  ) =>
  UnliftIO m ->
  GSEnv ->
  RawRequestBytes ->
  [ServiceHandler]
handlers run gsEnv body =
  [ unary (RPC :: RPC Service "getCfg") $
      runHandler getCfg,
    unary (RPC :: RPC Service "swapIntoLn") $
      runHandler Server.swapIntoLn,
    unary (RPC :: RPC Service "swapFromLn") $
      runHandler swapFromLn
  ]
  where
    runHandler ::
      (ContextMsg req res failure internal) =>
      (Entity User -> req -> m res) ->
      Wai.Request ->
      req ->
      IO res
    runHandler = withMiddleware run gsEnv body

extractPubKeyDer ::
  ( HasField req "maybe'ctx" (Maybe Proto.Ctx)
  ) =>
  req ->
  Maybe C.PubKey
extractPubKeyDer req = do
  ctx <- req ^? field @"maybe'ctx" . _Just
  C.importPubKey
    =<< ( ctx ^? Proto.maybe'lnPubKey . _Just . Proto.val
        )

verifySig ::
  ( HasContext req
  ) =>
  GSEnv ->
  Wai.Request ->
  req ->
  RawRequestBytes ->
  Either Text Bool
verifySig env waiReq req (RawRequestBytes payload) = do
  pubKey <- maybeToRight "No pub key in ctx" $ extractPubKeyDer req
  sig <- SU.sigFromReq (gsEnvSigHeaderName env) waiReq
  msg <- maybeToRight "Incorrect message" $ SU.prepareMsg payload
  if C.verifySig pubKey sig msg
    then Right True
    else Left "Signature verification fail"

withMiddleware ::
  ( ContextMsg req res failure internal,
    Env m
  ) =>
  UnliftIO m ->
  GSEnv ->
  RawRequestBytes ->
  (Entity User -> req -> m res) ->
  Wai.Request ->
  req ->
  IO res
withMiddleware (UnliftIO run) gsEnv body handler waiReq req =
  run $ do
    userE <- runExceptT $ do
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
      ExceptT $ User.createVerify pub nonce
    let isValidSigE = verifySig gsEnv waiReq req body
    let act =
          case (isValidSigE, userE) of
            (Right True, Right user) ->
              run . (setGrpcCtx <=< handler user)
            (_, Left e) ->
              const . pure $ failResE e
            (_, _) ->
              const . pure . failResE $
                FailureGrpcClient "Unknown error"
    liftIO $
      act req

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
