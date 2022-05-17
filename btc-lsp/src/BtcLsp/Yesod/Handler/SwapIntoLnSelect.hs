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

newSwapWidget ::
  SwapIntoLn.SwapInfo ->
  Maybe Widget
newSwapWidget swapInfo =
  newNamedListWidget MsgSwapInfo
    . singleton
    $ [ ( MsgSwapIntoLnUuid,
          Just
            . MsgProxy
            . UUID.toText
            . unUuid
            $ swapIntoLnUuid
        ),
        ( MsgSwapIntoLnUserId,
          Just $
            MsgProxy userPub
        ),
        ( MsgSwapIntoLnFundInvoice,
          Just
            . MsgProxy
            $ toText swapIntoLnFundInvoice
        ),
        ( MsgSwapIntoLnFundInvHash,
          Just
            . MsgProxy
            . toText
            $ into @RHashHex swapIntoLnFundInvHash
        ),
        ( MsgSwapIntoLnFundAddress,
          Just
            . MsgProxy
            $ toText swapIntoLnFundAddress
        ),
        ( MsgSwapIntoLnFundProof,
          MsgProxy
            . toHex
            . coerce
            <$> swapIntoLnFundProof
        ),
        ( MsgSwapIntoLnRefundAddress,
          Just
            . MsgProxy
            $ toText swapIntoLnRefundAddress
        ),
        ( MsgSwapIntoLnChanCapUser,
          Just
            . MsgSatoshiAmt
            $ from swapIntoLnChanCapUser
        ),
        ( MsgSwapIntoLnChanCapLsp,
          Just
            . MsgSatoshiAmt
            $ from swapIntoLnChanCapLsp
        ),
        ( MsgSwapIntoLnFeeLsp,
          Just
            . MsgSatoshiAmt
            $ from swapIntoLnFeeLsp
        ),
        ( MsgSwapIntoLnFeeMiner,
          Just
            . MsgSatoshiAmt
            $ from swapIntoLnFeeMiner
        ),
        ( MsgSwapIntoLnStatus,
          Just
            . MsgProxy
            $ inspectPlain swapIntoLnStatus
        ),
        ( MsgSwapIntoLnExpiresAt,
          Just
            . MsgProxy
            $ toPathPiece swapIntoLnExpiresAt
        ),
        ( MsgSwapIntoLnInsertedAt,
          Just
            . MsgProxy
            $ toPathPiece swapIntoLnInsertedAt
        ),
        ( MsgSwapIntoLnUpdatedAt,
          Just
            . MsgProxy
            $ toPathPiece swapIntoLnUpdatedAt
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
                MsgProxy
                  . inspectPlain @Word64
                  $ from blockHeight
              ),
              ( MsgTxId,
                MsgProxy
                  . txIdHex
                  $ coerce swapUtxoTxid
              ),
              ( MsgVout,
                MsgProxy
                  . inspectPlain @Word32
                  $ coerce swapUtxoVout
              ),
              ( MsgSat,
                MsgSatoshiAmt $
                  from swapUtxoAmount
              ),
              ( MsgStatus,
                MsgProxy $
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
                MsgProxy
                  . txIdHex
                  $ coerce lnChanFundingTxId
              ),
              ( MsgVout,
                MsgProxy
                  . inspectPlain @Word32
                  $ coerce lnChanFundingVout
              ),
              ( MsgStatus,
                MsgProxy $
                  inspectPlain lnChanStatus
              )
            ]
    )
      <$> chans
