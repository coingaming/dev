{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.About where

import qualified BtcLsp.Class.Env
import qualified BtcLsp.Math as Math
import BtcLsp.Yesod.Data.Widget
import BtcLsp.Yesod.Import

getAboutR :: Handler Html
getAboutR = do
  App {appMRunner = UnliftIO run} <- getYesod
  minAmt <- liftIO $ run getSwapIntoLnMinAmt
  mExamplesWidget <- liftIO . run $ newExamplesWidget minAmt
  defaultLayout $ do
    setTitleI MsgAboutRTitle
    $(widgetFile "about")

newExamplesWidget ::
  ( BtcLsp.Class.Env.Env m
  ) =>
  Money 'Usr 'OnChain 'Fund ->
  m (Maybe Widget)
newExamplesWidget minAmt = do
  caps <-
    mapM
      ( \amt -> do
          mcap <- Math.newSwapCapM amt
          pure $ (amt,) <$> mcap
      )
      [ minAmt,
        minAmt * 5,
        minAmt * 100
      ]
  pure
    . newListWidget
    $ ( \(fundAmt, Math.SwapCap {..}) ->
          [ ( MsgAboutExamplesUserOnChainFunding,
              MsgSatoshiAmt $
                from fundAmt
            ),
            ( MsgAboutExamplesLspSwapFee,
              MsgSatoshiAmt $
                from swapCapFee
            ),
            ( MsgAboutExamplesUserOutgoingCap,
              MsgSatoshiAmt $
                from swapCapUsr
            ),
            ( MsgAboutExamplesUserIncomingCap,
              MsgSatoshiAmt $
                from swapCapLsp
            ),
            ( MsgAboutExamplesTotalChanCap,
              MsgSatoshiAmt $
                from swapCapUsr
                  + from swapCapLsp
            )
          ]
      )
      <$> catMaybes caps
