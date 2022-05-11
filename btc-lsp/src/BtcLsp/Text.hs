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
import qualified Data.Text.Format.Numbers as F
import qualified Data.UUID as UUID
import qualified Data.UUID.V4 as UUID
import qualified Language.Haskell.TH.Syntax as TH

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
  displayRational1
    . (/ 1000)
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
displayRational len =
  F.prettyF
    F.PrettyCfg
      { F.pc_decimals = len,
        F.pc_thousandsSep = Just ',',
        F.pc_decimalSep = '.'
      }

displayRational1 :: Rational -> Text
displayRational1 =
  displayRational 1

mkHtmlUuid :: TH.Q TH.Exp
mkHtmlUuid =
  TH.lift
    . ("uuid-" <>)
    . UUID.toText
    =<< TH.runIO UUID.nextRandom
