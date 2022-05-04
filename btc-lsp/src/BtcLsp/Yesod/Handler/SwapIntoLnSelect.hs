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
  nodeUri <- liftIO $ run getLndNodeUri
  nodeUriHex <-
    eitherM
      (const badMethod)
      (pure . from @NodeUriHex @Text)
      . pure
      $ tryFrom nodeUri
  nodeUriQr <-
    maybeM badMethod pure
      . pure
      $ toQr nodeUriHex
  maybeM
    notFound
    ( \SwapIntoLn.SwapInfo {..} -> do
        let SwapIntoLn {..} = entityVal swapInfoSwap
        let (msgShort, msgLong, color) =
              case swapIntoLnStatus of
                SwapWaitingFundChain ->
                  ( MsgSwapIntoLnWaitingFundChainShort,
                    MsgSwapIntoLnWaitingFundChainLong,
                    Info
                  )
                SwapWaitingPeer ->
                  ( MsgSwapIntoLnFundedShort,
                    MsgSwapIntoLnFundedLong,
                    Info
                  )
                SwapWaitingChan ->
                  ( MsgSwapIntoLnWaitingChanShort,
                    MsgSwapIntoLnWaitingChanLong,
                    Info
                  )
                SwapWaitingFundLn ->
                  ( MsgSwapIntoLnWaitingFundLnShort,
                    MsgSwapIntoLnWaitingFundLnLong,
                    Info
                  )
                SwapSucceeded ->
                  ( MsgSwapIntoLnSucceededShort,
                    MsgSwapIntoLnSucceededLong,
                    Success
                  )
                SwapExpired ->
                  ( MsgSwapIntoLnExpiredShort,
                    MsgSwapIntoLnExpiredLong,
                    Danger
                  )
        let userPub =
              toHex
                . coerce
                . userNodePubKey
                $ entityVal swapInfoUser
        fundAddrQr <-
          maybeM badMethod pure
            . pure
            . toQr
            $ from swapIntoLnFundAddress
        mUtxoTableWidget <-
          if null swapInfoUtxo
            then pure Nothing
            else Just <$> newUtxoTableWidget swapInfoUtxo
        mChanTableWidget <-
          if null swapInfoChan
            then pure Nothing
            else Just <$> newChanTableWidget swapInfoChan
        let items =
              [ ( MsgSwapIntoLnUuid,
                  Just
                    . UUID.toText
                    . unUuid
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
                  Just $ inspectSatLabel swapIntoLnChanCapUser
                ),
                ( MsgSwapIntoLnChanCapLsp,
                  Just $ inspectSatLabel swapIntoLnChanCapLsp
                ),
                ( MsgSwapIntoLnFeeLsp,
                  Just $ inspectSatLabel swapIntoLnFeeLsp
                ),
                ( MsgSwapIntoLnFeeMiner,
                  Just $ inspectSatLabel swapIntoLnFeeMiner
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
          $(widgetFile "swap_into_ln_select")
    )
    . liftIO
    . run
    $ SwapIntoLn.getByUuid uuid
  where
    htmlUuid = $(mkHtmlUuid)

newUtxoTableWidget :: [SwapIntoLn.UtxoInfo] -> Handler Widget
newUtxoTableWidget utxos = do
  master <- getYesod
  langs <- languages
  pure $
    makeTableWidget
      (table $ renderMessage master langs)
      utxos
  where
    table render =
      textCol
        (render MsgBlock)
        ( inspectPlain @Word64
            . from
            . blockHeight
            . entityVal
            . SwapIntoLn.utxoInfoBlock
        )
        <> textColClass
          (HtmlClassAttr ["text-overflow"])
          (render MsgTxId)
          ( txIdHex
              . coerce
              . swapUtxoTxid
              . entityVal
              . SwapIntoLn.utxoInfoUtxo
          )
        <> textCol
          (render MsgVout)
          ( inspectPlain @Word32
              . coerce
              . swapUtxoVout
              . entityVal
              . SwapIntoLn.utxoInfoUtxo
          )
        <> textCol
          (render MsgSat)
          ( inspectSat
              . swapUtxoAmount
              . entityVal
              . SwapIntoLn.utxoInfoUtxo
          )
        <> textCol
          (render MsgStatus)
          ( inspectPlain
              . swapUtxoStatus
              . entityVal
              . SwapIntoLn.utxoInfoUtxo
          )

newChanTableWidget :: [Entity LnChan] -> Handler Widget
newChanTableWidget chans = do
  master <- getYesod
  langs <- languages
  pure $
    makeTableWidget
      (table $ renderMessage master langs)
      chans
  where
    table render =
      textColClass
        (HtmlClassAttr ["text-overflow"])
        (render MsgTxId)
        ( txIdHex
            . coerce
            . lnChanFundingTxId
            . entityVal
        )
        <> textCol
          (render MsgVout)
          ( inspectPlain @Word32
              . coerce
              . lnChanFundingVout
              . entityVal
          )
        <> textCol
          (render MsgStatus)
          ( inspectPlain
              . lnChanStatus
              . entityVal
          )

postSwapIntoLnSelectR :: Uuid 'SwapIntoLnTable -> Handler Html
postSwapIntoLnSelectR uuid = do
  App {appMRunner = UnliftIO run} <- getYesod
  maybeM
    notFound
    ( \swp -> do
        ((formResult, formWidget), formEnctype) <-
          runFormPost $
            renderBootstrap3
              BootstrapBasicForm
              (aForm $ SwapIntoLn.swapInfoSwap swp)
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
