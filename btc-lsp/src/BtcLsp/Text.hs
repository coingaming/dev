{-# LANGUAGE TypeApplications #-}

module BtcLsp.Text
  ( toHex,
    toQr,
    inspectSat,
    inspectSatLabel,
    mkHtmlUuid,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Import.External
import qualified Codec.QRCode as QR
  ( ErrorLevel (L),
    TextEncoding (Iso8859_1OrUtf8WithoutECI),
    defaultQRCodeOptions,
    encodeAutomatic,
  )
import qualified Codec.QRCode.JuicyPixels as JP
  ( toPngDataUrlT,
  )
import qualified Data.ByteString.Base16 as B16
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import qualified Language.Haskell.TH.Syntax as TH
import qualified Prelude

toHex :: ByteString -> Text
toHex =
  decodeUtf8
    . B16.encode

toQr :: Text -> Maybe Text
toQr =
  (toStrict . JP.toPngDataUrlT 4 5 <$>)
    . QR.encodeAutomatic
      (QR.defaultQRCodeOptions QR.L)
      QR.Iso8859_1OrUtf8WithoutECI

inspectSat ::
  Money
    (owner :: Owner)
    (btcl :: BitcoinLayer)
    (mrel :: MoneyRelation) ->
  Text
inspectSat =
  displayRational2
    . (/ 100)
    . into @Rational

inspectSatLabel ::
  Money
    (owner :: Owner)
    (btcl :: BitcoinLayer)
    (mrel :: MoneyRelation) ->
  Text
inspectSatLabel =
  (<> " sat")
    . inspectSat

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

mkHtmlUuid :: TH.Q TH.Exp
mkHtmlUuid =
  TH.lift
    . ("uuid-" <>)
    . UUID.toText
    =<< TH.runIO UUID.nextRandom
