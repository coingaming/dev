{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Grpc.Client.HighLevel
  ( swapIntoLn,
    swapIntoLnT,
    getCfg,
    getCfgT,
  )
where

import BtcLsp.Grpc.Client.LowLevel
import BtcLsp.Import
import qualified Data.Binary.Builder as BS
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL
import Data.ProtoLens.Field
import Data.ProtoLens.Message
import qualified LndClient.Data.VerifyMessage as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Network.GRPC.HTTP2.Encoding as G
import Network.GRPC.HTTP2.ProtoLens (RPC (..))
import Proto.BtcLsp (Service)
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Data.HighLevel_Fields as Proto
import qualified Proto.BtcLsp.Method.GetCfg as GetCfg
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn

swapIntoLn ::
  ( Env m
  ) =>
  GCEnv ->
  SwapIntoLn.Request ->
  m (Either Failure SwapIntoLn.Response)
swapIntoLn env req = withRunInIO $ \run ->
  first FailureGrpcClient
    <$> runUnary
      (RPC :: RPC Service "swapIntoLn")
      env
      ( \res sig compressMode ->
          run $
            verifySig res sig compressMode
      )
      req

swapIntoLnT ::
  ( Env m
  ) =>
  GCEnv ->
  SwapIntoLn.Request ->
  ExceptT Failure m SwapIntoLn.Response
swapIntoLnT env =
  ExceptT . swapIntoLn env

getCfg ::
  ( Env m
  ) =>
  GCEnv ->
  GetCfg.Request ->
  m (Either Failure GetCfg.Response)
getCfg env req = withRunInIO $ \run ->
  first FailureGrpcClient
    <$> runUnary
      (RPC :: RPC Service "getCfg")
      env
      ( \res sig compressMode ->
          run $
            verifySig res sig compressMode
      )
      req

getCfgT ::
  ( Env m
  ) =>
  GCEnv ->
  GetCfg.Request ->
  ExceptT Failure m GetCfg.Response
getCfgT env =
  ExceptT . getCfg env

-- | WARNING : this function is unsafe and inefficient
-- but it is used for testing purposes only!
verifySig ::
  ( Env m,
    Message msg,
    HasField msg "ctx" Proto.Ctx
  ) =>
  msg ->
  ByteString ->
  CompressMode ->
  m Bool
verifySig msg sig compressMode = do
  let msgEncoded =
        encodeMessage msg
  let msgChunk =
        case compressMode of
          Compressed -> G._compressionFunction G.gzip msgEncoded
          Uncompressed -> msgEncoded
  let msgWire =
        BS.pack
          [ case compressMode of
              Compressed -> 1
              Uncompressed -> 0
          ]
          <> ( BL.toStrict
                 . BS.toLazyByteString
                 . BS.putWord32be
                 . fromIntegral -- Length is non-neg, it's fine.
                 $ BS.length msgChunk
             )
          <> msgChunk
  let pub =
        msg
          ^. field @"ctx"
            . Proto.lnPubKey
            . Proto.val
  res <-
    withLnd
      Lnd.verifyMessage
      ( $
          Lnd.VerifyMessageRequest
            { Lnd.message = msgWire,
              Lnd.signature = sig,
              Lnd.pubkey = pub
            }
      )
  case res of
    Left e -> do
      $(logTM) ErrorS . logStr $
        "Client ==> signature verification failed "
          <> inspect e
      pure False
    Right x ->
      if coerce x
        then pure True
        else do
          $(logTM) ErrorS . logStr $
            "Client ==> signature verification failed "
              <> "for message of "
              <> inspect (BS.length msgWire)
              <> " bytes "
              <> inspect msgWire
              <> " with signature of "
              <> inspect (BS.length sig)
              <> " bytes "
              <> inspect sig
              <> " and pub key "
              <> inspect pub
          pure False
