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
  nodeCreds <-
    liftIO . run $
      (,) <$> getLspPubKey <*> getLndP2PSocketAddress
  nodeUri <-
    eitherM
      (const badMethod)
      (pure . from @NodeUri @Text)
      . pure
      $ tryFrom nodeCreds
  qrCodeSrc <-
    maybeM badMethod pure
      . pure
      $ toStrict . JP.toPngDataUrlT 4 5
        <$> QR.encodeAutomatic
          (QR.defaultQRCodeOptions QR.L)
          QR.Iso8859_1OrUtf8WithoutECI
          nodeUri
  defaultLayout $ do
    setTitleI MsgOpenChanRTitle
    $(widgetFile "open_chan")
