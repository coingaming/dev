{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapIntoLnCreate
  ( getSwapIntoLnCreateR,
    postSwapIntoLnCreateR,
  )
where

import BtcLsp.Data.Kind
import BtcLsp.Data.Type
import BtcLsp.Grpc.Combinator
import qualified BtcLsp.Grpc.Server.HighLevel as Server
import BtcLsp.Storage.Model
import BtcLsp.Storage.Model.User as User
import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import Lens.Micro
import qualified LndClient.Data.PayReq as Lnd
import qualified LndClient.RPC.Katip as Lnd
import qualified Proto.BtcLsp.Data.HighLevel as Proto
import qualified Proto.BtcLsp.Method.SwapIntoLn as SwapIntoLn
import qualified Proto.BtcLsp.Method.SwapIntoLn_Fields as SwapIntoLn
import Yesod.Form.Bootstrap3

data SwapRequest = SwapRequest
  { swapRequestInvoice :: LnInvoice 'Fund,
    swapRequestRefund :: UnsafeOnChainAddress 'Refund,
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
  renderPage Info formWidget formEnctype

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
          withLndServerT
            Lnd.decodePayReq
            ($ from fundInv)
        userEnt <-
          withExceptT
            ( const $
                newGenFailure
                  Proto.VERIFICATION_FAILED
                  $( mkFieldLocation
                       @SwapIntoLn.Request
                       [ "ctx",
                         "nonce"
                       ]
                   )
            )
            . ExceptT
            $ newNonce
              >>= runSql
                . User.createVerifySql
                  (Lnd.destination fundInvLnd)
        Server.swapIntoLnT
          userEnt
          (swapRequestRefund req)
          (swapRequestPrivacy req)
      case eSwap of
        Left e -> do
          setMessageI $ explainFailure e
          renderPage Danger formWidget formEnctype
        Right swapEnt ->
          redirect
            . SwapIntoLnSelectR
            . swapIntoLnUuid
            $ entityVal swapEnt
    _ ->
      renderPage Danger formWidget formEnctype

explainFailure :: SwapIntoLn.Response -> AppMessage
explainFailure res =
  maybe
    MsgInputFailure
    ( \case
        SwapIntoLn.Response'Failure'DEFAULT ->
          MsgInputFailure
        SwapIntoLn.Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_VALID ->
          MsgSwapIntoLnFailureRefundOnChainAddressIsNotValid
        SwapIntoLn.Response'Failure'REFUND_ON_CHAIN_ADDRESS_IS_NOT_SEGWIT ->
          MsgSwapIntoLnFailureRefundOnChainAddressIsNotSegwit
        SwapIntoLn.Response'Failure'InputFailure'Unrecognized {} ->
          MsgInputFailure
    )
    $ res
      ^? SwapIntoLn.maybe'failure
        . _Just
        . SwapIntoLn.specific
      >>= listToMaybe

renderPage :: BootstrapColor -> Widget -> Enctype -> Handler Html
renderPage color formWidget formEnctype = do
  let formRoute = SwapIntoLnCreateR
  let formMsgSubmit = MsgContinue
  panelLayout
    color
    MsgSwapIntoLnInfoShort
    MsgSwapIntoLnInfoLong
    $ do
      setTitleI MsgSwapIntoLnCreateRTitle
      $(widgetFile "simple_form")

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
      ( selectField $
          optionsPairs
            [ (MsgChanPublic, Public),
              (MsgChanPrivate, Private)
            ]
      )
      (bfs MsgChannelPrivacy)
      (Just Public)
