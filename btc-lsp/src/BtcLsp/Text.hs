{-# LANGUAGE TypeApplications #-}

module BtcLsp.Text
  ( toHex,
    inspectSat,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Data.ByteString.Base16 as B16
import qualified Prelude

toHex :: ByteString -> Text
toHex =
  decodeUtf8
    . B16.encode

inspectSat ::
  Money
    (owner :: Owner)
    (btcl :: BitcoinLayer)
    (mrel :: MoneyRelation) ->
  Text
inspectSat =
  (<> " sat")
    . displayRational2
    . (/ 100)
    . into @Rational

displayRational :: Int -> Rational -> Text
displayRational len rat =
  pack $
    (if num < 0 then "-" else "")
      <> Prelude.shows d ("." <> right)
  where
    right = case take len (go next) of
      "" -> "0"
      x -> x
    (d, next) = abs num `quotRem` den
    num = numerator rat
    den = denominator rat
    go 0 = ""
    go x =
      let (d', next') = (10 * x) `quotRem` den
       in Prelude.shows d' (go next')

displayRational2 :: Rational -> Text
displayRational2 =
  displayRational 2
