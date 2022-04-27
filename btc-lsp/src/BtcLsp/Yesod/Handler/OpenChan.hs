{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.OpenChan where

import BtcLsp.Class.Env
import BtcLsp.Yesod.Import
import qualified Codec.QRCode as QR
  ( ErrorLevel (L),
    TextEncoding (Iso8859_1OrUtf8WithoutECI),
    defaultQRCodeOptions,
    encodeAutomatic,
  )
import qualified Codec.QRCode.JuicyPixels as JP
  ( toPngDataUrlT,
  )

getOpenChanR :: Handler Html
getOpenChanR = do
  App {appMRunner = UnliftIO run} <- getYesod
  nodeUri <- liftIO $ run getLndNodeUri
  nodeUriHex <-
    eitherM
      (const badMethod)
      (pure . from @NodeUriHex @Text)
      . pure
      $ tryFrom nodeUri
  qrCodeSrc <-
    maybeM badMethod pure
      . pure
      $ toStrict . JP.toPngDataUrlT 4 5
        <$> QR.encodeAutomatic
          (QR.defaultQRCodeOptions QR.L)
          QR.Iso8859_1OrUtf8WithoutECI
          nodeUriHex
  defaultLayout $ do
    setTitleI MsgOpenChanRTitle
    $(widgetFile "open_chan")
  where
    htmlUuid = $(mkHtmlUuid)
