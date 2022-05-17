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
  newNamedListWidget MsgSwapIntoLnHeaderInfo
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
            . MsgSatoshi
            $ from swapIntoLnChanCapUser
        ),
        ( MsgSwapIntoLnChanCapLsp,
          Just
            . MsgSatoshi
            $ from swapIntoLnChanCapLsp
        ),
        ( MsgSwapIntoLnFeeLsp,
          Just
            . MsgSatoshi
            $ from swapIntoLnFeeLsp
        ),
        ( MsgSwapIntoLnFeeMiner,
          Just
            . MsgSatoshi
            $ from swapIntoLnFeeMiner
        ),
        ( MsgStatus,
          Just $
            swapStatusMsg swapIntoLnStatus
        ),
        ( MsgExpiresAt,
          Just $
            MsgUtcTime swapIntoLnExpiresAt
        ),
        ( MsgInsertedAt,
          Just $
            MsgUtcTime swapIntoLnInsertedAt
        ),
        ( MsgUpdatedAt,
          Just $
            MsgUtcTime swapIntoLnUpdatedAt
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
  newNamedListWidget MsgSwapIntoLnHeaderUtxos $
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
              ( MsgAmount,
                MsgSatoshi $
                  from swapUtxoAmount
              ),
              ( MsgStatus,
                swapUtxoStatusMsg swapUtxoStatus
              )
            ]
    )
      <$> utxos

newChanWidget :: [Entity LnChan] -> Maybe Widget
newChanWidget chans =
  newNamedListWidget MsgSwapIntoLnHeaderChans $
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
                lnChanStatusMsg lnChanStatus
              )
            ]
    )
      <$> chans

swapStatusMsg :: SwapStatus -> AppMessage
swapStatusMsg = \case
  SwapWaitingFundChain -> MsgSwapWaitingFundChain
  SwapWaitingPeer -> MsgSwapWaitingPeer
  SwapWaitingChan -> MsgSwapWaitingChan
  SwapWaitingFundLn -> MsgSwapWaitingFundLn
  SwapSucceeded -> MsgSwapSucceeded
  SwapExpired -> MsgSwapExpired

swapUtxoStatusMsg :: SwapUtxoStatus -> AppMessage
swapUtxoStatusMsg = \case
  SwapUtxoUsedForChanFunding -> MsgSwapUtxoUsedForChanFunding
  SwapUtxoRefunded -> MsgSwapUtxoRefunded
  SwapUtxoFirstSeen -> MsgSwapUtxoFirstSeen
  SwapUtxoOrphan -> MsgSwapUtxoOrphan

lnChanStatusMsg :: LnChanStatus -> AppMessage
lnChanStatusMsg = \case
  LnChanStatusPendingOpen -> MsgLnChanStatusPendingOpen
  LnChanStatusOpened -> MsgLnChanStatusOpened
  LnChanStatusActive -> MsgLnChanStatusActive
  LnChanStatusFullyResolved -> MsgLnChanStatusFullyResolved
  LnChanStatusInactive -> MsgLnChanStatusInactive
  LnChanStatusPendingClose -> MsgLnChanStatusPendingClose
  LnChanStatusClosed -> MsgLnChanStatusClosed
