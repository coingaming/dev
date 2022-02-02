module BtcLsp.Grpc.Sig
  (
    sigFromReq,
    prepareMsg
  )
where
import qualified Data.CaseInsensitive as CI
import Network.Wai.Internal (Request (..))
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString as BS
import qualified Crypto.Secp256k1 as C
import Universum
import qualified Crypto.Hash as CH
import qualified Data.ByteArray as BA
import qualified Data.Binary as B



sigFromReq :: ByteString -> Request -> Maybe C.Sig
sigFromReq sigHeaderName req = do
  let sigHeaderNameCI = CI.mk sigHeaderName
  (_, sig) <- find (\x -> fst x == sigHeaderNameCI) $ requestHeaders req
  C.importSig sig

prepareMsg :: ByteString -> Maybe C.Msg
prepareMsg m = C.msg $ BS.pack $ BA.unpack $ hash256 $ (BSL.drop 8 . B.encode) m
  where
    hash256 :: BSL.ByteString -> CH.Digest CH.SHA256
    hash256 = CH.hashlazy

