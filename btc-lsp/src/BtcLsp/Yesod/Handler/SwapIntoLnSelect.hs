{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.SwapIntoLnSelect
  ( getSwapIntoLnSelectR,
    postSwapIntoLnSelectR,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Storage.Model
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import Yesod.Form.Bootstrap3

getSwapIntoLnSelectR :: RHashHex -> Handler Html
getSwapIntoLnSelectR fundInvHash = do
  App {appMRunner = UnliftIO run} <- getYesod
  maybeM
    notFound
    ( \(swpEnt, usrEnt) -> do
        let SwapIntoLn {..} = entityVal swpEnt
        let userPub =
              toHex
                . coerce
                . userNodePubKey
                $ entityVal usrEnt
        let items =
              [ ( MsgSwapIntoLnUserId,
                  Just userPub
                ),
                ( MsgSwapIntoLnFundInvoice,
                  Just $ toText swapIntoLnFundInvoice
                ),
                ( MsgSwapIntoLnFundInvHash,
                  Just . toText $
                    into @RHashHex swapIntoLnFundInvHash
                ),
                ( MsgSwapIntoLnFundAddress,
                  Just $ toText swapIntoLnFundAddress
                ),
                ( MsgSwapIntoLnFundProof,
                  toHex . coerce
                    <$> swapIntoLnFundProof
                ),
                ( MsgSwapIntoLnFundInvoice,
                  Just $ toText swapIntoLnRefundAddress
                )
              ]
                >>= \case
                  (msg, Just txt) -> [(msg, txt)]
                  (_, Nothing) -> []
        defaultLayout $ do
          setTitleI $ MsgSwapIntoLnSelectRTitle fundInvHash
          $(widgetFile "simple_list_group")
    )
    . liftIO
    . run
    $ SwapIntoLn.getByRHashHex fundInvHash

postSwapIntoLnSelectR :: RHashHex -> Handler Html
postSwapIntoLnSelectR fundInvHash = do
  App {appMRunner = UnliftIO run} <- getYesod
  maybeM
    notFound
    ( \(swpEnt, _) -> do
        ((formResult, formWidget), formEnctype) <-
          runFormPost $
            renderBootstrap3
              BootstrapBasicForm
              (aForm swpEnt)
        case formResult of
          FormSuccess {} -> do
            App {appMRunner = UnliftIO {}} <- getYesod
            --
            -- TODO : !!!
            --
            renderPage fundInvHash formWidget formEnctype
          _ ->
            renderPage fundInvHash formWidget formEnctype
    )
    . liftIO
    . run
    $ SwapIntoLn.getByRHashHex fundInvHash

renderPage ::
  RHashHex ->
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

aForm :: Entity SwapIntoLn -> AForm Handler (Entity SwapIntoLn)
aForm (Entity entKey SwapIntoLn {..}) =
  Entity entKey
    <$> ( SwapIntoLn swapIntoLnUserId
            <$> areq
              fromTextField
              (bfsDisabled MsgSwapIntoLnFundInvoice)
              (Just swapIntoLnFundInvoice)
            <*> pure swapIntoLnFundInvHash
            <*> areq
              fromTextField
              (bfsDisabled MsgSwapIntoLnFundAddress)
              (Just swapIntoLnFundAddress)
            --
            -- TODO : show proof
            --
            <*> pure swapIntoLnFundProof
            <*> areq
              fromTextField
              (bfsDisabled MsgSwapIntoLnRefundAddress)
              (Just swapIntoLnRefundAddress)
            <*> pure swapIntoLnChanCapUser
            <*> pure swapIntoLnChanCapLsp
            <*> pure swapIntoLnFeeLsp
            <*> pure swapIntoLnFeeMiner
            <*> areq
              hiddenField
              (bfs MsgNothing)
              (Just swapIntoLnStatus)
            <*> areq
              hiddenField
              (bfs MsgNothing)
              (Just swapIntoLnExpiresAt)
            <*> pure swapIntoLnInsertedAt
            <*> pure swapIntoLnUpdatedAt
        )
