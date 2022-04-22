{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapIntoLnCreate where

import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import Yesod.Form.Bootstrap3

data SwapRequest = SwapRequest
  { swapRequestInvoice :: Text,
    swapRequestRefund :: Text,
    swapRequestPrivacy :: Privacy
  }
  deriving stock
    ( Eq,
      Ord,
      Show,
      Read,
      Generic
    )

instance Out SwapRequest

getSwapIntoLnCreateR :: Handler Html
getSwapIntoLnCreateR = do
  (formWidget, formEnctype) <-
    generateFormPost $
      renderBootstrap3
        BootstrapBasicForm
        aForm
  renderPage formWidget formEnctype

-- postSwapIntoLnCreateR :: Handler Html
-- postSwapIntoLnCreateR = do
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
--       redirect SwapIntoLnCreateR
--     _ ->
--       renderPage oldModel formWidget formEnctype

renderPage :: Widget -> Enctype -> Handler Html
renderPage formWidget formEnctype = do
  let formRoute = SwapIntoLnCreateR
  let formMsgSubmit = MsgContinue
  let form = $(widgetFile "simple_form")
  defaultLayout $ do
    setTitleI $ MsgSwapIntoLnCreateRTitle
    $(widgetFile "swap_into_ln_create")

aForm :: AForm Handler SwapRequest
aForm =
  SwapRequest
    <$> areq
      textField
      (bfsAutoFocus MsgSwapInvoice)
      Nothing
    <*> areq
      textField
      (bfs MsgRefundAddress)
      Nothing
    <*> areq
      (selectField optionsEnum)
      (bfs MsgChannelPrivacy)
      (Just Private)
