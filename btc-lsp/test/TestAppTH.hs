module TestAppTH
  ( mkPrvKey,
    deriveKeyPair,
  )
where

import Data.ByteString as BS
import qualified Data.Signable as Signable
import Language.Haskell.TH.Syntax
import Lsp.Import hiding (lift)

mkPrvKey :: Q Exp
mkPrvKey = do
  prvKey <- Signable.newRandomPrvKey Signable.AlgSecp256k1
  lift (BS.unpack $ Signable.exportPrvKeyRaw prvKey)

deriveKeyPair :: [Word8] -> (Signable.PrvKey, Signable.PubKey)
deriveKeyPair xs =
  case Signable.importPrvKeyRaw Signable.AlgSecp256k1 $ BS.pack xs of
    Nothing -> error "WRONG_PRV_KEY"
    Just x -> (x, Signable.derivePubKey x)
