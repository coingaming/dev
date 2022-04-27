{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapIntoLnCreate
  ( getSwapIntoLnCreateR,
    postSwapIntoLnCreateR,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import qualified BtcLsp.Grpc.Server.HighLevel as Server
import BtcLsp.Storage.Model
import BtcLsp.Storage.Model.User as User
import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import qualified LndClient.Data.PayReq as Lnd
import qualified LndClient.RPC.Katip as Lnd
import Yesod.Form.Bootstrap3

data SwapRequest = SwapRequest
  { swapRequestInvoice :: LnInvoice 'Fund,
    swapRequestRefund :: OnChainAddress 'Refund,
    swapRequestPrivacy :: Privacy
  }
  deriving stock
    ( Eq,
      Show,
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

postSwapIntoLnCreateR :: Handler Html
postSwapIntoLnCreateR = do
  ((formResult, formWidget), formEnctype) <-
    runFormPost $
      renderBootstrap3
        BootstrapBasicForm
        aForm
  case formResult of
    FormSuccess req -> do
      let fundInv = swapRequestInvoice req
      App {appMRunner = UnliftIO run} <- getYesod
      eSwap <- liftIO . run . runExceptT $ do
        fundInvLnd <-
          withLndT
            Lnd.decodePayReq
            ($ from fundInv)
        userEnt <-
          ExceptT $
            newNonce
              >>= User.createVerify (Lnd.destination fundInvLnd)
        Server.swapIntoLnT
          userEnt
          fundInv
          fundInvLnd
          $ swapRequestRefund req
      case eSwap of
        Left e -> do
          setMessageI . MsgFailure $ inspectPlain e
          renderPage formWidget formEnctype
        Right swapEnt ->
          redirect
            . SwapIntoLnSelectR
            . swapIntoLnUuid
            $ entityVal swapEnt
    _ ->
      renderPage formWidget formEnctype

renderPage :: Widget -> Enctype -> Handler Html
renderPage formWidget formEnctype = do
  let formRoute = SwapIntoLnCreateR
  let formMsgSubmit = MsgContinue
  let form = $(widgetFile "simple_form")
  defaultLayout $ do
    setTitleI MsgSwapIntoLnCreateRTitle
    $(widgetFile "swap_into_ln_create")

aForm :: AForm Handler SwapRequest
aForm =
  SwapRequest
    <$> areq
      fromTextField
      (bfsAutoFocus MsgSwapIntoLnFundInvoice)
      Nothing
    <*> areq
      fromTextField
      (bfs MsgSwapIntoLnRefundAddress)
      Nothing
    <*> areq
      (selectField optionsEnum)
      (bfs MsgChannelPrivacy)
      (Just Private)
