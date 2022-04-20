{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.OpenChan where

--import BtcLsp.Yesod.Data.Widget
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

--import qualified Database.Persist as P
--import Yesod.Form.Bootstrap3

getOpenChanR :: Handler Html
getOpenChanR = do
  let nodeUrl = "HELLOasdasdkjhalksjdlkasjhaslkjdsdalkfhdaslfkjhdasflkjhdagflkdfsjgldskfjgdslfkjhdslkfgjhdsflgkjhdsfglkdsjfgdslkjfhdslkfjhdsflgkjhdgslkdjhgqweqwelk;j;lkdsjsdfl;ksdjf;lsdkjds;lkfds;lkfjsdf;lkjdsf;ldskjfds;lkjfsd;lfkjsdf;lskjf;sdlkjfds;lfkjdsf;lksjfdsl;kjf" :: Text
  qrCodeSrc <-
    maybeM badMethod pure
      . pure
      $ toStrict . JP.toPngDataUrlT 4 5
        <$> QR.encodeAutomatic
          (QR.defaultQRCodeOptions QR.L)
          QR.Iso8859_1OrUtf8WithoutECI
          nodeUrl
  defaultLayout $ do
    setTitleI MsgOpenChanRTitle
    $(widgetFile "open_chan")

-- getOpenChanR :: Handler Html
-- getOpenChanR = do
--   (_, model) <- requireAuthPair
--   (formWidget, formEnctype) <-
--     generateFormPost $
--       renderBootstrap3
--         BootstrapBasicForm
--         (aForm model)
--   renderPage model formWidget formEnctype
--
-- postOpenChanR :: Handler Html
-- postOpenChanR = do
--   (modelId, oldModel) <- requireAuthPair
--   ((formResult, formWidget), formEnctype) <-
--     runFormPost $
--       renderBootstrap3
--         BootstrapBasicForm
--         (aForm oldModel)
--   case formResult of
--     FormSuccess newModel -> do
--       _ <-
--         runDB $
--           P.update
--             modelId
--             [ YesodUserName P.=. yesodUserName newModel,
--               YesodUserPassword P.=. yesodUserPassword newModel
--             ]
--       setMessageI MsgUpdated
--       redirect OpenChanR
--     _ ->
--       renderPage oldModel formWidget formEnctype
--
-- renderPage :: YesodUser -> Widget -> Enctype -> Handler Html
-- renderPage model formWidget formEnctype = do
--   let formRoute = OpenChanR
--   let formMsgSubmit = MsgUpdate
--   let form = $(widgetFile "simple_form")
--   defaultLayout $ do
--     setTitleI $ MsgOpenChanRTitle model
--     $(widgetFile "profile")
--
-- aForm :: YesodUser -> AForm Handler YesodUser
-- aForm x =
--   YesodUser
--     <$> areq
--       hiddenField
--       (bfs MsgNothing)
--       (Just $ yesodUserIdent x)
--     <*> aopt
--       textField
--       (bfsAutoFocus MsgName)
--       (Just $ yesodUserName x)
--     <*> aopt
--       textField
--       (bfs MsgPassword)
--       (Just $ yesodUserPassword x)
