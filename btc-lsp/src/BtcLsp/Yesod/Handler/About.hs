{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE NoImplicitPrelude #-}

module BtcLsp.Yesod.Handler.About where

import BtcLsp.Yesod.Import

getAboutR :: Handler Html
getAboutR =
  defaultLayout $ do
    setTitleI MsgAboutRTitle
    $(widgetFile "about")
