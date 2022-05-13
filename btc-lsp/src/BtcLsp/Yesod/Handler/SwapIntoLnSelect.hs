{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}

module BtcLsp.Yesod.Handler.SwapIntoLnSelect
  ( getSwapIntoLnSelectR,
  )
where

import BtcLsp.Data.Type
import BtcLsp.Storage.Model
import qualified BtcLsp.Storage.Model.SwapIntoLn as SwapIntoLn
import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import
import qualified Data.UUID as UUID

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
    ( \swapInfo@SwapIntoLn.SwapInfo {..} -> do
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
        fundAddrQr <-
          maybeM badMethod pure
            . pure
            . toQr
            $ from swapIntoLnFundAddress
        let mSwapWidget = newSwapWidget swapInfo
        let mUtxoWidget = newUtxoWidget swapInfoUtxo
        let mChanWidget = newChanWidget swapInfoChan
        panelLayout color msgShort msgLong $ do
          setTitleI $ MsgSwapIntoLnSelectRTitle swapIntoLnUuid
          $(widgetFile "swap_into_ln_select")
    )
    . liftIO
    . run
    . runSql
    $ SwapIntoLn.getByUuidSql uuid
  where
    htmlUuid = $(mkHtmlUuid)

newSwapWidget :: SwapIntoLn.SwapInfo -> Maybe Widget
newSwapWidget swapInfo =
  newNamedListWidget MsgSwapInfo
    . singleton
    $ [ ( MsgSwapIntoLnUuid,
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
          Just $ toMessage swapIntoLnChanCapUser
        ),
        ( MsgSwapIntoLnChanCapLsp,
          Just $ toMessage swapIntoLnChanCapLsp
        ),
        ( MsgSwapIntoLnFeeLsp,
          Just $ toMessage swapIntoLnFeeLsp
        ),
        ( MsgSwapIntoLnFeeMiner,
          Just $ toMessage swapIntoLnFeeMiner
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
  where
    SwapIntoLn {..} =
      entityVal $
        SwapIntoLn.swapInfoSwap swapInfo
    userPub =
      toHex
        . coerce
        . userNodePubKey
        . entityVal
        $ SwapIntoLn.swapInfoUser swapInfo

newUtxoWidget :: [SwapIntoLn.UtxoInfo] -> Maybe Widget
newUtxoWidget utxos =
  newNamedListWidget MsgSwapUtxos $
    ( \row ->
        let SwapUtxo {..} =
              entityVal $ SwapIntoLn.utxoInfoUtxo row
            Block {..} =
              entityVal $ SwapIntoLn.utxoInfoBlock row
         in [ ( MsgBlock,
                inspectPlain @Word64 $ from blockHeight
              ),
              ( MsgTxId,
                txIdHex $ coerce swapUtxoTxid
              ),
              ( MsgVout,
                inspectPlain @Word32 $ coerce swapUtxoVout
              ),
              ( MsgSat,
                toMessage swapUtxoAmount
              ),
              ( MsgStatus,
                inspectPlain swapUtxoStatus
              )
            ]
    )
      <$> utxos

newChanWidget :: [Entity LnChan] -> Maybe Widget
newChanWidget chans =
  newNamedListWidget MsgSwapChans $
    ( \row ->
        let LnChan {..} = entityVal row
         in [ ( MsgTxId,
                txIdHex $ coerce lnChanFundingTxId
              ),
              ( MsgVout,
                inspectPlain @Word32 $ coerce lnChanFundingVout
              ),
              ( MsgStatus,
                inspectPlain lnChanStatus
              )
            ]
    )
      <$> chans
