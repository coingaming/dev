{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.Profile where

import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import qualified Database.Persist as P
import Yesod.Form.Bootstrap3

getProfileR :: Handler Html
getProfileR = do
  (_, model) <- requireAuthPair
  (formWidget, formEnctype) <-
    generateFormPost $
      renderBootstrap3
        BootstrapBasicForm
        (aForm model)
  renderPage model formWidget formEnctype

postProfileR :: Handler Html
postProfileR = do
  (modelId, oldModel) <- requireAuthPair
  ((formResult, formWidget), formEnctype) <-
    runFormPost $
      renderBootstrap3
        BootstrapBasicForm
        (aForm oldModel)
  case formResult of
    FormSuccess newModel -> do
      _ <-
        runDB $
          P.update
            modelId
            [ YesodUserName P.=. yesodUserName newModel,
              YesodUserPassword P.=. yesodUserPassword newModel
            ]
      setMessageI MsgUpdated
      redirect ProfileR
    _ ->
      renderPage oldModel formWidget formEnctype

renderPage :: YesodUser -> Widget -> Enctype -> Handler Html
renderPage model formWidget formEnctype = do
  let formRoute = ProfileR
  let formMsgSubmit = MsgUpdate
  let form = $(widgetFile "simple_form")
  defaultLayout $ do
    setTitleI $ MsgProfileRTitle model
    $(widgetFile "profile")

aForm :: YesodUser -> AForm Handler YesodUser
aForm x =
  YesodUser
    <$> areq
      hiddenField
      (bfs MsgNothing)
      (Just $ yesodUserIdent x)
    <*> aopt
      textField
      (bfsAutoFocus MsgName)
      (Just $ yesodUserName x)
    <*> aopt
      textField
      (bfs MsgPassword)
      (Just $ yesodUserPassword x)
