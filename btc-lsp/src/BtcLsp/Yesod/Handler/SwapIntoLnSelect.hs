{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapIntoLnSelect
  ( getSwapIntoLnSelectR,
    postSwapIntoLnSelectR,
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

getSwapIntoLnSelectR :: HexSha256 (LnInvoice 'Fund) -> Handler Html
getSwapIntoLnSelectR fundInvHash = do
  (formWidget, formEnctype) <-
    generateFormPost $
      renderBootstrap3
        BootstrapBasicForm
        aForm
  renderPage fundInvHash formWidget formEnctype

postSwapIntoLnSelectR :: HexSha256 (LnInvoice 'Fund) -> Handler Html
postSwapIntoLnSelectR fundInvHash = do
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
          setMessageI . MsgFailure $ inspect e
          renderPage fundInvHash formWidget formEnctype
        Right swapEnt ->
          redirect
            . SwapIntoLnSelectR
            . from
            . swapIntoLnFundInvHash
            $ entityVal swapEnt
    _ ->
      renderPage fundInvHash formWidget formEnctype

renderPage ::
  HexSha256 (LnInvoice 'Fund) ->
  Widget ->
  Enctype ->
  Handler Html
renderPage fundInvHash formWidget formEnctype = do
  let formRoute = SwapIntoLnSelectR fundInvHash
  let formMsgSubmit = MsgContinue
  let form = $(widgetFile "simple_form")
  defaultLayout $ do
    setTitleI $ MsgSwapIntoLnSelectRTitle fundInvHash
    $(widgetFile "swap_into_ln_create")

aForm :: AForm Handler SwapRequest
aForm =
  SwapRequest
    <$> areq
      fromTextField
      (bfsAutoFocus MsgSwapInvoice)
      Nothing
    <*> areq
      fromTextField
      (bfs MsgRefundAddress)
      Nothing
    <*> areq
      (selectField optionsEnum)
      (bfs MsgChannelPrivacy)
      (Just Private)
