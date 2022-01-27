{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Grpc.Client.HighLevel
  ( swapIntoLn,
    swapIntoLnT,
  )
where

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
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import Proto.SignableOrphan ()

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
      (\res sig -> run $ verifySig res sig)
      req

swapIntoLnT ::
  ( Env m
  ) =>
  GCEnv ->
  SwapIntoLn.Request ->
  ExceptT Failure m SwapIntoLn.Response
swapIntoLnT env =
  ExceptT . swapIntoLn env

-- | WARNING : this function is unsafe and inefficient
-- but it is used for testing purposes only!
verifySig ::
  ( Env m,
    Message msg,
    HasField msg "ctx" Proto.Ctx
  ) =>
  msg ->
  ByteString ->
  m Bool
verifySig msg sig = do
  let msgCompressed =
        G._compressionFunction G.gzip $
          encodeMessage msg
  let msgWire =
        BS.pack [1]
          <> ( BL.toStrict
                 . BS.toLazyByteString
                 . BS.putWord32be
                 . fromIntegral
                 $ BS.length msgCompressed
             )
          <> msgCompressed
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
