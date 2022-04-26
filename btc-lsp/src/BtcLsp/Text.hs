module BtcLsp.Text
  ( toHex,
  )
where

import BtcLsp.Import.External
import qualified Data.ByteString.Base16 as B16

toHex :: ByteString -> Text
toHex =
  decodeUtf8
    . B16.encode
