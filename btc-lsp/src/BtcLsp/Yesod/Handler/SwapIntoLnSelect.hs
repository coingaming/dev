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
import qualified Data.UUID as UUID
import Yesod.Form.Bootstrap3

getSwapIntoLnSelectR :: Uuid 'SwapIntoLnTable -> Handler Html
getSwapIntoLnSelectR uuid = do
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
              [ ( MsgSwapIntoLnUuid,
                  Just
                    . UUID.toText
                    . from
                    $ swapIntoLnUuid
                ),
                ( MsgSwapIntoLnUserId,
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
                ( MsgSwapIntoLnRefundAddress,
                  Just $ toText swapIntoLnRefundAddress
                ),
                ( MsgSwapIntoLnChanCapUser,
                  Just $ inspectSat swapIntoLnChanCapUser
                ),
                ( MsgSwapIntoLnChanCapLsp,
                  Just $ inspectSat swapIntoLnChanCapLsp
                ),
                ( MsgSwapIntoLnFeeLsp,
                  Just $ inspectSat swapIntoLnFeeLsp
                ),
                ( MsgSwapIntoLnFeeMiner,
                  Just $ inspectSat swapIntoLnFeeMiner
                ),
                ( MsgSwapIntoLnStatus,
                  Just $ inspectPlain swapIntoLnStatus
                ),
                ( MsgSwapIntoLnExpiresAt,
                  Just $ toPathPiece swapIntoLnExpiresAt
                ),
                ( MsgSwapIntoLnInsertedAt,
                  Just $ toPathPiece swapIntoLnInsertedAt
                ),
                ( MsgSwapIntoLnUpdatedAt,
                  Just $ toPathPiece swapIntoLnUpdatedAt
                )
              ]
                >>= \case
                  (msg, Just txt) -> [(msg, txt)]
                  (_, Nothing) -> []
        defaultLayout $ do
          setTitleI $ MsgSwapIntoLnSelectRTitle swapIntoLnUuid
          $(widgetFile "simple_list_group")
    )
    . liftIO
    . run
    $ SwapIntoLn.getByUuid uuid

postSwapIntoLnSelectR :: Uuid 'SwapIntoLnTable -> Handler Html
postSwapIntoLnSelectR uuid = do
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
            renderPage uuid formWidget formEnctype
          _ ->
            renderPage uuid formWidget formEnctype
    )
    . liftIO
    . run
    $ SwapIntoLn.getByUuid uuid

renderPage ::
  Uuid 'SwapIntoLnTable ->
  Widget ->
  Enctype ->
  Handler Html
renderPage uuid formWidget formEnctype = do
  let formRoute = SwapIntoLnSelectR uuid
  let formMsgSubmit = MsgContinue
  let form = $(widgetFile "simple_form")
  defaultLayout $ do
    setTitleI $ MsgSwapIntoLnSelectRTitle uuid
    $(widgetFile "swap_into_ln_create")

aForm :: Entity SwapIntoLn -> AForm Handler (Entity SwapIntoLn)
aForm (Entity entKey SwapIntoLn {..}) =
  Entity entKey
    <$> ( SwapIntoLn swapIntoLnUuid swapIntoLnUserId
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
