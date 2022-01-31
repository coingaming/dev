module BtcLsp.Grpc.SignatureUtils
  (
    sigFromReq,
    findBitString,
    parsePubKeyPem,
    prepareMsg,
    verifySig
  )
where
import qualified Data.CaseInsensitive as CI
import qualified Data.Text.Encoding as TE
import Network.Wai.Internal (Request (..))
import qualified Data.ByteString.Lazy as BSL
import qualified Data.ByteString as BS
import qualified Crypto.Secp256k1 as C
import qualified Data.PEM as P
import Universum
import qualified Data.ASN1.Encoding as ASN1
import qualified Data.ASN1.BinaryEncoding as ASN1
import qualified Data.ASN1.Prim as ASN1
import qualified Data.ASN1.BitArray as ASN1
import qualified Data.List as L
import qualified Crypto.Hash as CH
import qualified Data.ByteArray as BA
import qualified Data.Binary as B



sigFromReq :: ByteString -> Request -> Maybe C.Sig
sigFromReq sigHeaderName req = do
  let sigHeaderNameCI = CI.mk sigHeaderName
  (_, sig) <- find (\x -> fst x == sigHeaderNameCI) $ requestHeaders req
  C.importSig sig

safeHeadEither :: String -> [a] -> Either String a
safeHeadEither _ [x] = Right x
safeHeadEither msg _ = Left $ msg <> " Not one chunk"

findBitString :: [ASN1.ASN1] -> Either String ByteString
findBitString arr =
  let masn = L.find (\case (ASN1.BitString (ASN1.BitArray _ _)) -> True; _ -> False) arr
  in case masn of
       Just (ASN1.BitString (ASN1.BitArray _ x)) -> Right x
       _ -> Left "Cannot find asn1 bitstring"

-- prettyPrint :: ByteString -> String
-- prettyPrint = foldr showHex ""

parsePubKeyPem :: ByteString -> Either String C.PubKey
parsePubKeyPem pbs = do
  pem <- P.pemParseBS pbs >>= safeHeadEither "pubkey"
  asns <- first show $ ASN1.decodeASN1 ASN1.DER (BSL.fromStrict $ P.pemContent pem)
  der <- findBitString asns
  maybeToRight "Failed to import der" $ C.importPubKey der

pubKeyFromEnv :: Text -> Either String C.PubKey
pubKeyFromEnv key = parsePubKeyPem $ TE.encodeUtf8 key

prepareMsg :: ByteString -> Maybe C.Msg
prepareMsg m = C.msg $ BS.pack $ BA.unpack $ hash256 $ (BSL.drop 8 . B.encode) m
  where
    hash256 :: BSL.ByteString -> CH.Digest CH.SHA256
    hash256 = CH.hashlazy

verifySig :: Text -> ByteString -> Request -> ByteString -> Either String Bool
verifySig pubK sigHeaderName req payload = do
  pubKey <- pubKeyFromEnv pubK
  sig <- maybeToRight "Incorrect signature" $ sigFromReq sigHeaderName req
  msg <- maybeToRight "Incorrect message" $ prepareMsg payload
  if C.verifySig pubKey sig msg then Right True else Left "Signature verification fail"
