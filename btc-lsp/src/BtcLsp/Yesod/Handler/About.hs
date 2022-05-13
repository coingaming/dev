{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.About where

import qualified BtcLsp.Math as Math
import BtcLsp.Yesod.Import

getAboutR :: Handler Html
getAboutR = do
  App {appMRunner = UnliftIO run} <- getYesod
  minAmt <- liftIO $ run getSwapIntoLnMinAmt
  defaultLayout $ do
    setTitleI MsgAboutRTitle
    $(widgetFile "about")
