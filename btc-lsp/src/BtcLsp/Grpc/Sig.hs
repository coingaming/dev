module BtcLsp.Grpc.Sig
  ( sigFromReq,
    prepareMsg,
  )
where

import BtcLsp.Import.External
import qualified Crypto.Hash as CH
import qualified Crypto.Secp256k1 as C
import qualified Data.Binary as B
import qualified Data.ByteArray as BA
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64.URL as B64
import qualified Data.ByteString.Lazy as BSL
import qualified Data.CaseInsensitive as CI
import qualified Data.Text as T
import Network.Wai.Internal (Request (..))

sigFromReq :: SigHeaderName -> Request -> Either Text C.Sig
sigFromReq sigHeaderName req = do
  (_, b64sig) <-
    maybeToRight
      ( "missing "
          <> sigHeaderNameText
          <> " header"
      )
      . find (\x -> fst x == sigHeaderNameCI)
      $ requestHeaders req
  sigDer <-
    first
      ( \e ->
          "signature "
            <> sigHeaderNameText
            <> " import from base64 payload "
            <> inspectPlain b64sig
            <> " failed with error "
            <> T.pack e
      )
      $ B64.decode b64sig
  maybeToRight
    ( "signature "
        <> sigHeaderNameText
        <> " import from der payload "
        <> inspectPlain sigDer
        <> " failed"
    )
    $ C.importSig sigDer
  where
    sigHeaderNameText =
      from sigHeaderName
    sigHeaderNameBS =
      from sigHeaderName
    sigHeaderNameCI =
      CI.mk sigHeaderNameBS

prepareMsg :: ByteString -> Maybe C.Msg
prepareMsg m = C.msg $ BS.pack $ BA.unpack $ hash256 $ (BSL.drop 8 . B.encode) m
  where
    hash256 :: BSL.ByteString -> CH.Digest CH.SHA256
    hash256 = CH.hashlazy
