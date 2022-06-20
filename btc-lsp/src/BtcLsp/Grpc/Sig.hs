module BtcLsp.Grpc.Sig
  ( MsgToSign (..),
    LndSig (..),
    sigToVerify,
    msgToVerify,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Grpc.Data
import BtcLsp.Import.External
import qualified Crypto.Hash as CH
import qualified Crypto.Secp256k1 as C
import qualified Data.ByteArray as BA
import qualified Data.ByteString as BS
import qualified Data.ByteString.Base64 as B64
import qualified Data.CaseInsensitive as CI
import Network.Wai.Internal (Request (..))

newtype MsgToSign = MsgToSign
  { unMsgToSign :: ByteString
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      NFData
    )
  deriving stock
    ( Generic
    )

instance Out MsgToSign

newtype LndSig = LndSig
  { unLndSig :: ByteString
  }
  deriving newtype
    ( Eq,
      Ord,
      Show,
      NFData
    )
  deriving stock
    ( Generic
    )

instance Out LndSig

sigToVerify :: SigHeaderName -> Request -> Either Failure C.Sig
sigToVerify sigHeaderName waiReq = do
  (_, b64sig) <-
    maybeToRight
      ( FailureGrpc $
          "Missing "
            <> sigHeaderNameText
            <> " header"
      )
      . find (\x -> fst x == sigHeaderNameCI)
      $ requestHeaders waiReq
  let sigDer =
        B64.decodeLenient b64sig
  maybeToRight
    ( FailureGrpc $
        "Signature "
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

msgToVerify :: ByteString -> Maybe C.Msg
msgToVerify =
  C.msg
    . BS.pack
    . BA.unpack
    . hash256
  where
    hash256 :: ByteString -> CH.Digest CH.SHA256
    hash256 = CH.hash
