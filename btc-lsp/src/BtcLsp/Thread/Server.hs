{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Thread.Server
  ( apply,
  )
where

import BtcLsp.Grpc.Data
import qualified BtcLsp.Grpc.Server.HighLevel as Server
import BtcLsp.Grpc.Server.LowLevel
import qualified BtcLsp.Grpc.Sig as Sig
import BtcLsp.Import
import qualified BtcLsp.Storage.Model.User as User
import qualified Crypto.Secp256k1 as C
import qualified Data.ByteString as BS
import Data.ProtoLens.Field
import Lens.Micro
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Network.GRPC.Server
import qualified Network.Wai.Internal as Wai
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Method.SwapFromLn as SwapFromLn
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import qualified Universum

apply :: (Env m) => m ()
apply = do
  env <- getGsEnv
  withUnliftIO $ \run ->
    runServer env $ handlers run

handlers ::
  forall m.
  ( Env m
  ) =>
  UnliftIO m ->
  GSEnv ->
  RawRequestBytes ->
  [ServiceHandler]
handlers run gsEnv body =
  [ unary (RPC :: RPC Service "swapIntoLn") $
      runHandler Server.swapIntoLn,
    unary (RPC :: RPC Service "swapFromLn") $
      runHandler swapFromLn,
    unary (RPC :: RPC Service "getCfg") $
      runHandler Server.getCfg
  ]
  where
    runHandler ::
      ( GrpcReq req,
        GrpcRes res failure specific internal,
        Out req,
        Out res
      ) =>
      (Entity User -> req -> m res) ->
      Wai.Request ->
      req ->
      IO res
    runHandler =
      withMiddleware run gsEnv body

verifySigE ::
  GSEnv ->
  Wai.Request ->
  NodePubKey ->
  RawRequestBytes ->
  Either Failure ()
verifySigE env waiReq pubNode (RawRequestBytes payload) = do
  pubDer <-
    maybeToRight
      ( FailureGrpc $
          "NodePubKey DER import failed from "
            <> inspectPlain pubNode
      )
      . C.importPubKey
      $ coerce pubNode
  sig <-
    Sig.sigToVerify (gsEnvSigHeaderName env) waiReq
  msg <-
    maybeToRight
      ( FailureGrpc $
          "Incorrect message from "
            <> inspectPlain payload
      )
      $ Sig.msgToVerify payload
  if C.verifySig pubDer sig msg
    then pure ()
    else
      Left
        . FailureGrpc
        $ "Signature verification failed with key "
          <> inspectPlain pubDer
          <> " signature "
          <> inspectPlain sig
          <> " message "
          <> inspectPlain payload
          <> " of "
          <> inspectPlain (BS.length payload)
          <> " bytes and message hash "
          <> inspectPlain (C.getMsg msg)

withMiddleware ::
  ( GrpcReq req,
    GrpcRes res failure specific internal,
    Env m,
    Out req,
    Out res
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
      --
      -- NOTE : Here request type is hardcoded,
      -- because it's impossible to use generic "req"
      -- type with TH. Hardcoding request type is not ideal,
      -- because theoretically other requests could have
      -- other location of context stuff,
      -- but not really in this case.
      --
      nonce <-
        fromReqT
          $( mkFieldLocation
               @SwapIntoLn.Request
               [ "ctx",
                 "nonce"
               ]
           )
          $ req
            ^? field @"maybe'ctx"
              . _Just
              . Proto.maybe'nonce
              . _Just
      pub <-
        fromReqT
          $( mkFieldLocation
               @SwapIntoLn.Request
               [ "ctx",
                 "ln_pub_key"
               ]
           )
          $ req
            ^? field @"maybe'ctx"
              . _Just
              . Proto.maybe'lnPubKey
              . _Just
      if gsEnvSigVerify gsEnv
        then
          except
            . first
              ( const $
                  newGenFailure
                    Proto.VERIFICATION_FAILED
                    mempty
              )
            $ verifySigE gsEnv waiReq pub body
        else
          $(logTM)
            ErrorS
            "WARNING!!! SIGNATURE VERIFICATION DISABLED!!!"
      withExceptT
        ( const $
            newGenFailure
              Proto.VERIFICATION_FAILED
              $( mkFieldLocation
                   @SwapIntoLn.Request
                   [ "ctx",
                     "nonce"
                   ]
               )
        )
        . ExceptT
        . runSql
        $ User.createVerifySql pub nonce
    case userE of
      Right user -> do
        res <- setGrpcCtx =<< handler user req
        $(logTM) DebugS . logStr $ debugMsg res
        pure res
      Left e -> do
        $(logTM) DebugS . logStr $ debugMsg e
        pure e
  where
    debugMsg :: (Out a) => a -> Text
    debugMsg x =
      "Got input "
        <> inspect body
        <> " with Wai request "
        <> Universum.show waiReq
        <> " and decoded "
        <> inspect req
        <> " producing result "
        <> inspect x

swapFromLn ::
  ( Monad m
  ) =>
  Entity User ->
  SwapFromLn.Request ->
  m SwapFromLn.Response
swapFromLn _ _ =
  --
  -- TODO : implement!!!
  --
  pure defMessage
